//
//  ContentView.swift
//  vima
//
//  Created by Josh Kwok on 2023/12/15.
//

import SwiftUI
import Combine

class ContentViewState: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var displayInvalidLoginAlert: Bool = false
}

struct ContentView: View {
    private let verticalPaddingForForm = 40
    @ObservedObject var state: ContentViewState
    var body: some View {
        GeometryReader { geo in
            ZStack {
                HStack {
                    Spacer()
                    VStack(spacing: CGFloat(verticalPaddingForForm)) {
                        Text("**Let's Meditate together.**")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        TextField("User Name:", text: $state.username)
                            .padding()
                            .background(.thinMaterial)
                            .opacity(0.5)
                            .cornerRadius(5.0)
                            .padding(.bottom, 20)
                        SecureField("Enter a password", text: $state.password)
                            .padding()
                            .background(.thinMaterial)
                            .opacity(0.5)
                            .cornerRadius(5.0)
                            .padding(.bottom, 20)
                        VStack {
                            Text("Sign in").onTapGesture {
                                print("Signing in...")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 220, height: 60)
                            .background(Color.opacity(Color.secondary)(0.8))
                            .cornerRadius(15.0)
                            .padding(.bottom, 30)
                            Text("Sign up").onTapGesture {
                                print("Signing up...")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 220, height: 60)
                            .background(Color.opacity(Color.secondary)(0.8))
                            .cornerRadius(15.0)
                        }
                    }
                    .frame(width: geo.size.width / 2, height: geo.size.height, alignment: .center)
                    .onTapGesture {
                        self.endEditing()
                    }
                    Spacer()
                }
                .alert("Invalid username or password", isPresented: $state.displayInvalidLoginAlert) {
                    Button("OK", role: .cancel) { }
                }
            }

        }
    }
}

extension ContentView {
    private func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
}
