//
//  Payload.swift
//  vima
//
//  Created by Josh Kwok on 2023/12/15.
//

import Foundation

enum Payload {
    enum User {
        enum Auth {
            struct Credentials: Codable {
                let name: String
                let password: String
            }

            struct Response: Decodable {
                let status: Bool
                let message: String?
                let token: String?
                let userData: Data?
            }
        }
        struct Data: Decodable {
            let id: Int
            let name: String
            let phone: String?
        }
    }

    struct Music: Codable, Equatable, Identifiable, Hashable {
        let id: Int
        let title: String?
        let artist: String?
        let url: String
        let duration: Float
    }

}
