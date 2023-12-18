//
//  AgoraService.swift
//  OMApp
//
//  Created by Josh Kwok on 2021/11/5.
//

import AgoraRtcKit
import Combine
import Foundation
import SwiftUI

enum BroadcasterError: Error {
    case EmptyAgoraKitInstance
    case JoinAgoraChannelError(errCode: Int32)
    case InitError
    case EmptyTokenValue
    case LeaveAgoraChannelError(errCode: Int32)
}

class Broadcaster: NSObject, AgoraRtcEngineDelegate, ObservableObject {
    var channelName: String
    var uid: UInt
    var role: AgoraClientRole
    var recordingConfig: AgoraAudioRecordingConfiguration?
    @State private var cancellables = Set<AnyCancellable>()
    @State private var initialized: Bool = false
    @State private var joined: Bool = false
    private(set) var token: String?
    private var bags = Set<AnyCancellable>()
    var agoraKit: AgoraRtcEngineKit!

    var connectionState: AgoraConnectionState {
        agoraKit.getConnectionState()
    }

    init(channelName: String, role: AgoraClientRole, uid: UInt) {
        self.channelName = channelName
        self.role = role
        self.uid = uid
        super.init()
    }

    func initialize() -> AnyPublisher<Broadcaster, Error> {
        let result = PassthroughSubject<Broadcaster, Error>()
        setupAgoraKit(delegate: self)
        fetchToken(channelName: channelName, role: role, uid: uid)?
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error in generating token:", error)
                    result.send(completion: .failure(error))
                }
            }, receiveValue: { [weak self] tokenResponse in
                guard let self = self else { return }
                self.configureAgoraKit(with: tokenResponse.token, agoraKit: agoraKit)
                result.send(self)
            })
            .store(in: &bags)

        return result.eraseToAnyPublisher()
    }


    func joinChannel() -> AnyPublisher<Bool, Error> {
        if initialized {
            return performJoinChannel(self)
        } else {
            return initialize()
                .catch { error -> AnyPublisher<Broadcaster, Error> in
                    // Handle the error
                    print("Error initializing AgoraService:", error)
                    return Fail(error: BroadcasterError.InitError)
                        .eraseToAnyPublisher()
                }
                .flatMap { [weak self] broadcaster -> AnyPublisher<Bool, Error> in
                    guard let self = self else {
                        return Fail(error: BroadcasterError.InitError)
                            .eraseToAnyPublisher()
                    }
                    return self.performJoinChannel(broadcaster)
                }
                .eraseToAnyPublisher()
        }
    }

    func leaveChannel() -> AnyPublisher<Bool, Error> {
        let result = PassthroughSubject<Bool, Error>()
        let agoraRes = agoraKit.leaveChannel { stats in
            self.joined = false
            result.send(true)
            print("left channel \(self.channelName) after \(stats.duration) secs")
        }
        if agoraRes != 0 {
            print("error on leaving channel \(self.channelName) with error code: \(agoraRes)")
            result.send(completion: .failure(BroadcasterError.LeaveAgoraChannelError(errCode: agoraRes)))
        }
        return result.eraseToAnyPublisher()
    }

    func startRecording() -> Int32 {
        if let _agoraKit = agoraKit, let _recordingConfig = recordingConfig {
            print("recording saved to ", _recordingConfig.filePath as Any)
            return _agoraKit.startAudioRecording(withConfig: _recordingConfig)
        }
        else {
            return -1
        }
    }

    func stopRecording() -> Int32 {
        if let _agoraKit = agoraKit, let _recordingConfig = recordingConfig {
            let res = _agoraKit.stopAudioRecording()
            if res == 0 {
                if let filePath = _recordingConfig.filePath {
                    let audioUrl = URL(fileURLWithPath: filePath)
                    print("audioUrl: ", audioUrl)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        do {
                            let myData = try Data(contentsOf: audioUrl)
                            print(myData.count, myData)
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            return res
        }
        return -1
    }

    // MARK: - Private

    private func setupAgoraKit(delegate _: Broadcaster) {
        let config = AgoraRtcEngineConfig()
        config.appId = Config.Agora.APP_ID
        config.areaCode = AgoraAreaCodeType.global
        let logConfig = AgoraLogConfig()
        logConfig.level = .info
        config.logConfig = logConfig
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
    }

    private struct TokenResponse: Decodable {
        var code: String
        var token: String
    }

    private struct TokenRequestParams: Encodable {
        let uid: UInt
        let channelName: String
        let role: Int
    }

    private func fetchToken(channelName: String, role: AgoraClientRole, uid: UInt) -> AnyPublisher<TokenResponse, Error>? {
        let networkService = NetworkService(baseURL: Config.Servers.TOKEN)
        let param = TokenRequestParams(uid: uid, channelName: channelName, role: role.rawValue)

        return networkService.post(param, to: "/")
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    private func timestamp() -> String {
        String(Int(Date().timeIntervalSinceReferenceDate))
    }

    private func setupAgoraAudioRecordingConfig() -> AgoraAudioRecordingConfiguration {
        let recordingConfig = AgoraAudioRecordingConfiguration.init()
        recordingConfig.filePath = getDocumentsDirectory().appendingPathComponent("\(timestamp()).aac").path
        recordingConfig.quality = .medium
        return recordingConfig
    }


    private func configureAgoraKit(with token: String, agoraKit: AgoraRtcEngineKit) {
        print("Received token value: \(token) for channel \(channelName)")
        self.token = token
        agoraKit.setChannelProfile(.liveBroadcasting)
        agoraKit.setClientRole(role)
        agoraKit.disableVideo()
        agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        agoraKit.setEnableSpeakerphone(true)
        agoraKit.enableAudioVolumeIndication(200, smooth: 3, reportVad: true)
        recordingConfig = setupAgoraAudioRecordingConfig()
        initialized = true
    }

    private func performJoinChannel(_ broadcaster: Broadcaster) -> AnyPublisher<Bool, Error> {
        let result = PassthroughSubject<Bool, Error>()
        guard let token = broadcaster.token else {
            result.send(completion: .failure(BroadcasterError.EmptyTokenValue))
            return result.eraseToAnyPublisher()
        }

        let agoraRes = agoraKit.joinChannel(
            byToken: token,
            channelId: broadcaster.channelName,
            info: nil,
            uid: broadcaster.uid
        ) { [weak self] _, _, elapsed in
            DispatchQueue.main.async {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            self?.joined = true
            result.send(true)
            print("Joined channel: \(broadcaster.channelName) ok, within time: \(elapsed)")
        }

        if agoraRes != 0 {
            result.send(completion: .failure(BroadcasterError.JoinAgoraChannelError(errCode: agoraRes)))
        }

        return result.eraseToAnyPublisher()
    }


    // MARK: - Delegate

    func rtcEngine(_: AgoraRtcEngineKit,
                   reportAudioVolumeIndicationOfSpeakers _: [AgoraRtcAudioVolumeInfo],
                   totalVolume: Int)
    {
        //
    }

    func rtcEngineConnectionDidLost(_: AgoraRtcEngineKit) {
        print("rtc connection lost")
    }

    func rtcEngineConnectionDidInterrupted(_: AgoraRtcEngineKit) {
        print("rtc connection is interrupted")
    }

    internal func rtcEngine(_: AgoraRtcEngineKit, connectionChangedTo state: AgoraConnectionState, reason: AgoraConnectionChangedReason) {
        //
    }
}
