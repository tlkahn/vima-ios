//
//  MainView.swift
//  vima
//
//  Created by Josh Kwok on 2023/12/15.
//

import Foundation
import SwiftUI
import AgoraRtcKit

struct MainView: View {
    @State private var toCreateRoom: Bool = false
    @State private var toFollowedList: Bool = false
    @State private var toUserProfile: Bool = false
    @State private var menuFolded = true

    var body: some View {
        VStack {
            Text("Hello world!")
            FloatingMenuView(buttons: ["plus", "heart", "person"], onClick: { title in
                print("title")
                switch title {
                case "plus":
                    resetNavigationDestinations()
                    toCreateRoom = true
                case "heart":
                    resetNavigationDestinations()
                    toFollowedList = true
                case "person":
                    resetNavigationDestinations()
                    toUserProfile = true
                default:
                    break
                }
                menuFolded = true
            }, folded: $menuFolded)
        }
        .navigationDestination(isPresented: $toCreateRoom) {
            // TODO: get user var after log in
            let channelName = "user.name"
            let uid: UInt = 12345
            let role: AgoraClientRole = .broadcaster
            RoomView(channelName: channelName, role: role, uid: uid)
        }
        .navigationDestination(isPresented: $toFollowedList) {
            FollowedListView()
        }
        .navigationDestination(isPresented: $toUserProfile) {
            UserProfileView()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("Main View", displayMode: .inline)
    }
}

extension MainView {
    private func resetNavigationDestinations () {
        toCreateRoom = false
        toFollowedList = false
        toUserProfile = false
    }
}


struct FollowedListView: View {
    var body: some View {
        Text("Followed Users List")
    }
}

struct UserProfileView: View {
    var body: some View {
        Text("User Profile")
    }
}

extension MainView {
    enum DestinationView {
        case createRoom
        case followedList
        case userProfile
    }
}
