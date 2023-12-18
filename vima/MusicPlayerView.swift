//
//  MusicPlayerView.swift
//  vima
//
//  Created by Josh Kwok on 2023/12/15.
//
import AVKit
import Combine
import Foundation
import SwiftUI

struct TransparentBackgroundLinearProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .progressViewStyle(LinearProgressViewStyle(tint: Color.blue))
            .background(Color.gray)
    }
}

struct PlayPauseButton: View {
    let music: Payload.Music
    let isPlaying: Bool
    let musicInPlay: Payload.Music?
    let playAction: () -> Void
    let pauseAction: () -> Void

    var body: some View {
        Button(action: {
            if music == musicInPlay && isPlaying {
                pauseAction()
            } else {
                playAction()
            }
        }, label: {
            Image(systemName: music == musicInPlay && isPlaying ? "pause" : "play")
                .foregroundColor(.primary)
                .font(.body)
        })
        .padding(.all, 20)
        .background(.background)
        .clipShape(Circle())
        .transition(.move(edge: .trailing))
    }
}


struct MusicListView: View {
    let appConfig = Config.shared
    @State var musicList: [Payload.Music]? = nil
    @State private var musicInPlay: Payload.Music? = nil
    @State private var audioPlayer: AVPlayer? = nil
    @State private var cancellables = Set<AnyCancellable>()
    @State private var isPlaying: Bool = false
    @State private var playbackProgress:
      [Payload.Music: (played: Double, progressValue: Double)] = [:]
    @State private var updateTimer: Timer?

    var body: some View {
        ForEach(musicList ?? [], id: \.self) { music in
            HStack {
                Text(music.title ?? "")
                Spacer()
                PlayPauseButton(
                    music: music,
                    isPlaying: isPlaying,
                    musicInPlay: musicInPlay,
                    playAction: { self.play(music: music) },
                    pauseAction: { self.pause() }
                ).onAppear {
                    updateTimer = Timer.scheduledTimer(
                        withTimeInterval: 1,
                        repeats: true
                    ) { _ in updatePlaybackProgress() }
                }
            }
            .background(Color.gray.opacity(0.2)) // Add a gray background to the HStack
            ProgressView(value: progressBinding(for: music).wrappedValue)
                .progressViewStyle(TransparentBackgroundLinearProgressViewStyle())
                .frame(height: 2)
                .padding(.top, -11) // Add negative padding to move the ProgressView up
                .opacity(0.5)
            .opacity(0.5)
        }
        .padding(.vertical, 4)
        .onAppear {
            loadMusicList()
        }
        .onDisappear {
            updateTimer?.invalidate()
            stop()
        }
    }

}

extension MusicListView {

    func play(music: Payload.Music?) {
        guard let music = music, let url = URL(string: music.url) else { return }

        if music == musicInPlay, let player = audioPlayer, !isPlaying {
            player.play()
        } else {
            stop()
            let playerItem = AVPlayerItem(url: url)
            audioPlayer = AVPlayer(playerItem: playerItem)

            // Resume playback from the stored played time
            if let storedProgress = playbackProgress[music] {
                audioPlayer?.seek(to: CMTime(
                    seconds: storedProgress.played,
                    preferredTimescale: 1
                ))
            }
            audioPlayer?.play()
            musicInPlay = music
        }
        isPlaying = true
    }

    func stop() {
        audioPlayer?.pause()
        audioPlayer = nil
        musicInPlay = nil
        isPlaying = false
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }

    func loadMusicList() {
        let networkService = NetworkService(baseURL: self.appConfig.baseURL)

        networkService.get(from: "/musics")
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching music list: \(error)")
                case .finished:
                    print("Music list fetch completed.")
                }
            } receiveValue: { (musicList: [Payload.Music]) in
                self.musicList = musicList
            }.store(in: &cancellables)

    }

    private func progressValue(for music: Payload.Music) -> Double {
        guard
          let player = audioPlayer,
          let item = player.currentItem,
          music == musicInPlay else {
            return 0
        }

        let played = item.currentTime().seconds
        let total = item.duration.seconds

        if total.isFinite && total > 0 {
            return played / total
        } else {
            return 0
        }
    }

    private func updatePlaybackProgress() {
        guard
          let player = audioPlayer,
          let item = player.currentItem,
          let music = musicInPlay else {
            return
        }

        let played = item.currentTime().seconds
        let total = item.duration.seconds
        let progressValue = total.isFinite && total > 0 ? played / total : 0

        playbackProgress[music] = (played: played, progressValue: progressValue)
    }


    private func progressBinding(for music: Payload.Music) -> Binding<Double> {
        return .init(
          get: {
            self.playbackProgress[music]?.progressValue ?? 0
        },
          set: { newValue in
            self.playbackProgress[music]?.progressValue = newValue
        })
    }
}

enum MusicPlayerError: Error {
    case emptyMusic
}
