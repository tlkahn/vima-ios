//
//  WebsocketManager.swift
//  vima
//
//  Created by Josh Kwok on 2023/12/18.
//

import Foundation

// Example usage: 
//let webSocketManager = WebSocketManager()
//webSocketManager.connect()
class WebSocketManager: NSObject, URLSessionDelegate {
    var webSocketTask: URLSessionWebSocketTask?
    lazy var urlSession: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    }()
    var heartbeatTimer: Timer?

    override init() {
        super.init()
    }

    func connect() {
        let userId = "your_user_id" // TODO: Replace this with the actual user ID
        let url = URL(string: "wss://yourserver.com/cable?user_id=\(userId)")!
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        listen()
        startHeartbeat()
    }

    func disconnect() {
        heartbeatTimer?.invalidate()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }

    func sendHeartbeat() {
        let message = URLSessionWebSocketTask.Message.string("heartbeat")
        webSocketTask?.send(message) { error in
            if let error = error {
                print("Error sending heartbeat: \(error)")
            }
        }
    }

    func listen() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received string: \(text)")
                case .data(let data):
                    print("Received data: \(data)")
                default:
                    break
                }

                self?.listen()
            }
        }
    }

    private func startHeartbeat() {
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.sendHeartbeat()
        }
    }
}

extension WebSocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket did connect")
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket did disconnect")
    }
}

