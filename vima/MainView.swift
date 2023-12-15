//
//  MainView.swift
//  vima
//
//  Created by Josh Kwok on 2023/12/15.
//

import Foundation
import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Text("Hello world!")
            FloatingMenuView(buttons: ["plus", "heart", "person"], onClick: {title in print(title)}, state: FloatMenuViewState())
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("Main View", displayMode: .inline)
    }
}
