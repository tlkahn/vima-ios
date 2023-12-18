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
    private let appConfig = Config.shared
    // By using the `@State` property wrapper, you ensure that the
    // `cancellables` set will persist across view updates and manage the
    // lifecycle of Combine subscriptions. When the `ContentView` is
    // deinitialized, any subscriptions stored in `cancellables` will be
    // automatically canceled.
    @State private var cancellables = Set<AnyCancellable>()
    @State private var isAuthenticated = false
    @ObservedObject var state: ContentViewState
    var body: some View {
        NavigationStack {
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
                                    signin()
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
                                    signup()
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
            .navigationDestination(isPresented: $isAuthenticated) {
                MainView()
            }
        }

    }
}

extension ContentView {
    private func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }

    private enum UserAuthType {
        case signup
        case signin
    }

    private func performAuthentication(credentials: Payload.User.Auth.Credentials, authType: UserAuthType) {
        let networkService = NetworkService(baseURL: appConfig.baseURL)

        let endpoint: String

        switch authType {
        case .signin:
            endpoint = "/login"
        case .signup:
            endpoint = "/register"
        }

        networkService.post(credentials, to: endpoint)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: \(error)")
                }
            }, receiveValue: { (response: Payload.User.Auth.Response) in
                print("Success: Received response - \(response)")
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                }
            }).store(in: &cancellables)
    }

    private func signin() {
        let credentials = Payload.User.Auth.Credentials(name: state.username, password: state.password)
        performAuthentication(credentials: credentials, authType: .signin)
    }

    private func signup() {
        let credentials = Payload.User.Auth.Credentials(name: state.username, password: state.password)
        performAuthentication(credentials: credentials, authType: .signup)
    }

}
