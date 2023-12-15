//
//  vimaApp.swift
//  vima
//
//  Created by Josh Kwok on 2023/12/15.
//

import SwiftUI

@main
struct vimaApp: App {
    var body: some Scene {
        WindowGroup {
            let contentViewState = ContentViewState()
            ContentView(state: contentViewState)
        }
    }
}
