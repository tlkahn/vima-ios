//
//  RoomView.swift
//  vima
//
//  Created by Josh Kwok on 2023/12/15.
//

import Foundation
import SwiftUI

struct RoomView: View {
    @State private var menuFolded = true
    var host: Bool
    var body: some View {
        Text("Room View - Host: \(host ? "Yes" : "No")")
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
    }
}
