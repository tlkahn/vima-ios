//
//  Config.swift
//  vima
//
//  Created by Josh Kwok on 2023/12/15.
//

import Foundation

enum Config {
    static let BG_VIDEO_URL = Bundle.main.url(forResource: "Smoke_Sheet_4K_Motion_Background_Loop", withExtension: "mp4")!
    static let BASE_URL = "http://localhost:3000"
    enum Agora {
        static let APP_ID = ""
        
    }
    enum Deployment {
        enum Phase {
            case dev
            case test
            case prod
        }
    }
    static let APP_DEPLOYMENT_PHASE: Deployment.Phase = .dev
    enum Servers {
        private static func load() -> [String: [String: String]]? {
            guard let url = Bundle.main.url(forResource: "server_config", withExtension: "plist"),
                  let data = try? Data(contentsOf: url) else {
                return nil
            }
            return try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: [String: String]]
        }

        private static let data = load()

        private static func value(for key: String) -> String {
            switch APP_DEPLOYMENT_PHASE {
            case .dev:
                return data?["dev"]?[key] ?? ""
            case .test:
                return data?["test"]?[key] ?? ""
            case .prod:
                return data?["prod"]?[key] ?? ""
            }
        }

        static var TOKEN: String {
            return value(for: "TOKEN_SERVER")
        }
    }
}
