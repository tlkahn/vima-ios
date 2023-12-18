//
//  vimaApp.swift
//  vima
//
//  Created by Josh Kwok on 2023/12/15.
//

import SwiftUI
import AgoraRtcKit

@main
struct vimaApp: App {
    var body: some Scene {
        WindowGroup {
//            let contentViewState = ContentViewState()
//            ContentView(state: contentViewState)
            let channelName = "user.name"
            let uid: UInt = 12345
            let role: AgoraClientRole = .broadcaster
            RoomView(channelName: channelName, role: role, uid: uid)
        }
    }
}
