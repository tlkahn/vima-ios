//
//  NetworkService.swift
//  vima
//
//  Created by Josh Kwok on 2023/12/15.
//

import Foundation
import Combine

struct NetworkService {
    let baseURL: String
    private func getToken() -> String? {
        return UserDefaults.standard.object(forKey: "token") as? String
    }

    func get<U>(from: String) -> AnyPublisher<U, Error> where U: Decodable {
        let url = URL(string: baseURL + from)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if getToken() != nil {
            request.setValue("Bearer \(getToken()!)", forHTTPHeaderField: "Authorization")
        }
        return run(request)
    }

    func post<T, U>(_ entry: T, to: String) -> AnyPublisher<U, Error>
        where T: Encodable, U: Decodable
    {
        let url = URL(string: baseURL + to)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if getToken() != nil {
            request.setValue("Bearer \(getToken()!)", forHTTPHeaderField: "Authorization")
        }
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(entry)
        request.httpBody = jsonData
        return run(request)
    }

    func run<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        let decoder = JSONDecoder()
        var result: AnyPublisher<T,Error>
        do {
            result = URLSession.shared
                .dataTaskPublisher(for: request)
                .map { $0.data }
                .handleEvents(receiveOutput: { print("<<< Data received:\n", NSString(
                    data: $0,
                    encoding: String.Encoding.utf8.rawValue
                )!) })
                .decode(type: T.self, decoder: decoder)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        return result
    }
}
