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
            Text("Hello, World!")
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("Main View", displayMode: .inline)
    }
}
