//
//  Config.swift
//  vima
//
//  Created by Josh Kwok on 2023/12/15.
//

import Foundation

enum DeploymentPhase {
    case dev
    case test
    case prod
}

struct Config {
    static let shared = Config()

    private init() {} // Disable the constructor for singleton

    let bgVideoURL = Bundle.main.url(forResource: "Smoke_Sheet_4K_Motion_Background_Loop", withExtension: "mp4")!
    let baseURL = "http://localhost:3000"
    let agoraAppID = "ed48e0cee69e41ffa303e26737ec210f"


    let appDeploymentPhase: DeploymentPhase = .dev

    struct Servers {
        private let data: [String: [String: String]]

        init() {
            guard let url = Bundle.main.url(forResource: "servers", withExtension: "plist"),
                  let data = try? Data(contentsOf: url),
                  let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: [String: String]] else {
                self.data = [:]
                return
            }
            self.data = plist
        }

        func value(for key: String, deploymentPhase: DeploymentPhase) -> String {
            switch deploymentPhase {
            case .dev:
                return data["dev"]?[key] ?? ""
            case .test:
                return data["test"]?[key] ?? ""
            case .prod:
                return data["prod"]?[key] ?? ""
            }
        }
    }

    static let servers = Servers()
}

// Usage
// let config = Config.shared
// let tokenServer = config.servers.value(for: "TOKEN_SERVER", deploymentPhase: config.appDeploymentPhase)
