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
    // By using the `@State` property wrapper, you ensure that the
    // `cancellables` set will persist across view updates and manage the
    // lifecycle of Combine subscriptions. When the `ContentView` is
    // deinitialized, any subscriptions stored in `cancellables` will be
    // automatically canceled.
    @State private var cancellables = Set<AnyCancellable>()
    @ObservedObject var state: ContentViewState
    var body: some View {
        GeometryReader { geo in
            ZStack {
                BackgroundPlayerView()
                    .background(Color.opacity(Color.black)(0.7))
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
                            .onTapGesture {
                                login()
                            }
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

    private func login() {
        let networkService = NetworkService(rootUrl: "http://localhost:3000")
        let credentials = Payload.LoginCredentials(name: state.username, password: state.password)
        networkService.post(credentials, to: "/login").sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: \(error)")
                }
            }, receiveValue: { (response: Payload.LoginResponse) in
                print("Success: Received response - \(response)")
            }).store(in: &cancellables)

    }
}
