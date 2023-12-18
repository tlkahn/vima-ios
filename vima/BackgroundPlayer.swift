//
//  BackgroundPlayerView.swift
//  OMApp
//
//  Created by Josh Kwok on 2022/1/6.
//

import AVFoundation
import AVKit
import Foundation
import SwiftUI

struct BackgroundPlayerView: UIViewRepresentable {
    static let loopingPlayerView = LoopingPlayerUIView(frame: .zero)
    static var player = loopingPlayerView.player
    static let config = Config.shared

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    var videoUrl: URL? = config.bgVideoURL

    class Coordinator: NSObject {
        var parent: BackgroundPlayerView

        init(_ parent: BackgroundPlayerView) {
            self.parent = parent
        }
    }

    func updateUIView(_: UIView, context _: UIViewRepresentableContext<BackgroundPlayerView>) {}

    func makeUIView(context: Context) -> UIView {
        Self.loopingPlayerView.setVideo(url: context.coordinator.parent.videoUrl!)
        return Self.loopingPlayerView
    }
}

class LoopingPlayerUIView: UIView {
    var playerLayer: AVPlayerLayer
    var player: AVQueuePlayer
    private var playerLooper: AVPlayerLooper?
    private var videoUrl: URL?

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setVideo(url: URL) {
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        player = .init(playerItem: item)
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        playerLooper = AVPlayerLooper(player: player, templateItem: item)
        player.play()
    }

    override init(frame: CGRect) {
        playerLayer = .init()
        player = .init()
        super.init(frame: frame)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
