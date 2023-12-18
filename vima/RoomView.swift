//
//  RoomView.swift
//  vima
//
//  Created by Josh Kwok on 2023/12/15.
//

import Foundation
import SwiftUI
import Combine
import AgoraRtcKit

struct RoomView: View {
    @State private var menuFolded = true
    @StateObject private var broadcaster: Broadcaster
    @State private var joinResult: Result<Bool, Error>?
    @State private var cancellables = Set<AnyCancellable>()

    init(channelName: String, role: AgoraClientRole, uid: UInt) {
        _broadcaster = StateObject(wrappedValue: Broadcaster(channelName: channelName, role: role, uid: uid))
    }

    var body: some View {
        FloatingMenuView(buttons: [ "heart", "music.quarternote.3", "record.circle", "xmark"], onClick: { title in
            print(title)
            switch title {
            case "heart":
                break
            case "music.quarternote.3":
                break
            case "record.circle":
                break
            case "xmark":
                break
            default:
                break
            }
            menuFolded = true
        }, folded: $menuFolded)
        .onAppear {
            initializeAndJoinChannel()
        }
    }

    private func initializeAndJoinChannel() {
        broadcaster.initialize()
            .flatMap { [weak broadcaster] _ -> AnyPublisher<Bool, Error> in
                guard let broadcaster = broadcaster else {
                    return Fail(error: BroadcasterError.InitError)
                           .eraseToAnyPublisher()
                }
                return broadcaster.joinChannel()
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    joinResult = .failure(error)
                }
            }, receiveValue: { success in
                joinResult = .success(success)
            })
            .store(in: &cancellables)
    }
}

enum BroadcasterError: Error {
    case InitError
}
