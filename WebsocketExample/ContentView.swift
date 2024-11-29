//
//  ContentView.swift
//  WebsocketExample
//
//  Created by Nghia Tran on 29/11/24.
//

import SwiftUI

struct ContentView: View {
    @State private var webSocketTask: URLSessionWebSocketTask?
    @State private var messages: [String] = []
    @State private var messageText: String = ""
    @State private var isConnected: Bool = false
    
    var body: some View {
        VStack {
            // Connection status and button
            HStack {
                Circle()
                    .fill(isConnected ? .green : .red)
                    .frame(width: 10, height: 10)
                Button(isConnected ? "Disconnect" : "Connect") {
                    isConnected ? disconnect() : connect()
                }
            }
            
            // Messages display
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(messages, id: \.self) { message in
                        Text(message)
                            .padding(.vertical, 2)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            
            // Message input and send button
            HStack {
                TextField("Message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    sendMessage()
                }
                .disabled(!isConnected)
            }
        }
        .padding()
    }
    
    private func connect() {
        let url = URL(string: "wss://echo.websocket.org")! // Example echo server
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        isConnected = true
        receiveMessage()
    }
    
    private func disconnect() {
        webSocketTask?.cancel()
        webSocketTask = nil
        isConnected = false
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        let message = URLSessionWebSocketTask.Message.string(messageText)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("Error sending message: \(error)")
            } else {
                DispatchQueue.main.async {
                    messages.append("Sent: \(messageText)")
                    messageText = ""
                }
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        messages.append("Received: \(text)")
                    }
                case .data(let data):
                    print("Received binary data: \(data)")
                @unknown default:
                    break
                }
                receiveMessage() // Continue receiving messages
            case .failure(let error):
                print("Error receiving message: \(error)")
                DispatchQueue.main.async {
                    isConnected = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
