//
//  Payload.swift
//  vima
//
//  Created by Josh Kwok on 2023/12/15.
//

import Foundation

enum Payload {
    struct LoginCredentials: Codable {
        let name: String
        let password: String
    }
    struct UserData: Decodable {
        let id: Int
        let name: String
        let phone: String?
    }
    struct LoginResponse: Decodable {
        let status: Bool
        let message: String?
        let token: String?
        let userData: UserData?
    }

}
