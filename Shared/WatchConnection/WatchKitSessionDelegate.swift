//
//  WatchKitSessionDelegate.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 21.07.21.
//

import Combine
import ComposableArchitecture
import Foundation
import WatchConnectivity

#if os(watchOS)
import ClockKit
#endif

public class WatchKitSessionDelegate: NSObject, WCSessionDelegate {
    var continuation: AsyncStream<WatchKitSessionClient.Action>.Continuation?

    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard activationState == .activated else { return }
        self.continuation?.yield(.sessionDidActivate(activationState))
    }

    #if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        self.continuation?.yield(.sessionDidBecomeInactive)
    }

    public func sessionDidDeactivate(_ session: WCSession) {
        self.continuation?.yield(.sessionDidDeactivate)
    }
    #endif

    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        self.continuation?.yield(.didReceiveMessage(message))
    }

    public func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        do {
            let message = try JSONDecoder().decode(WCSessionData.self, from: messageData)
            self.continuation?.yield(.didReceiveMessageData(message))
        } catch {
            print(error.localizedDescription)
        }
    }
}
