//
//  WCSessionManager.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 2/14/25.
//

import Foundation
import WatchConnectivity

class WCSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WCSessionManager() // Singleton instance
    
    @Published var receivedMessage: String = "" // Data to update SwiftUI views

    private override init() {
        super.init()
        setupSession()
    }

    private func setupSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // Send a message to the Watch
    func sendMessage(_ message: [String: Any]) {
        if WCSession.default.isPaired {
            if WCSession.default.isWatchAppInstalled {
                WCSession.default.sendMessage(message, replyHandler: nil) { error in
                    print("WCSession Error: \(error.localizedDescription)")
                }
            }
        }
    }

    // Receive message from Watch
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let text = message["message"] as? String {
                self.receivedMessage = text
            }
        }
    }

    // Required WCSession delegate methods
    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
