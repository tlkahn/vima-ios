//
//  FloatMenuView.swift
//  vima
//
//  Created by Josh Kwok on 2023/12/15.
//

import Foundation
import SwiftUI

class FloatMenuViewState: ObservableObject {
    @Published var folded: Bool = true
}

struct FloatingMenuView: View {
    let buttons: [String]
    let onClick: (String) -> Void
    @ObservedObject var state: FloatMenuViewState

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                ForEach(state.folded ? ["ellipsis"] : buttons + ["minus"], id: \.self) { button in
                    Button(action: {
                        withAnimation {
                            if button == "ellipsis" || button == "minus" {
                                state.folded.toggle()
                            } else {
                                onClick(button)
                            }
                        }
                    }, label: {
                        Image(systemName: button)
                            .foregroundColor(.primary)
                            .font(button == "ellipsis" || button == "minus" ? .headline : .body)
                            .frame(width: 60, height: 60)
                    })
                    .clipShape(Circle())
                    .padding(.all, 10)
                }
            }
        }.padding(.all, 10)
    }
}
