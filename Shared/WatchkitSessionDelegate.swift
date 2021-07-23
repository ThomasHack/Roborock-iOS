//
//  WatchkitSessionDelegate.swift
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

public class WatchkitSessionDelegate: NSObject, WCSessionDelegate {
    private let session: WCSession

    let sessionDidActivate: () -> Void
    // let sessionDidDeactivate:() -> Void
    // let sessionDidBecomeInactive: () -> Void
    // let sessionWatchStateDidChange: () -> Void
    let didReceiveMessage: ([String: Any]) -> Void
    // let didReceiveMessageWithReplyHandler: ([String: Any], @escaping ([String: Any]) -> Void) -> Void
    // let didReceiveMessageData: (Data) -> Void
    // let didReceiveMessageDataWithReplyHandler: (Data, @escaping (Data) -> Void) -> Void

    public init(
        session: WCSession = .default,
        sessionDidActivate: @escaping() -> Void,
        // sessionDidDeactivate: @escaping() -> Void,
        // sessionDidBecomeInactive: @escaping() -> Void,
        // sessionWatchStateDidChange: @escaping() -> Void,
        didReceiveMessage: @escaping([String: Any]) -> Void
        // didReceiveMessageWithReplyHandler: @escaping([String: Any], @escaping ([String: Any]) -> Void) -> Void,
        // didReceiveMessageData: @escaping((Data) -> Void),
        // didReceiveMessageDataWithReplyHandler: @escaping((Data, @escaping (Data) -> Void) -> Void)
    ) {
        self.session = session
        self.sessionDidActivate = sessionDidActivate
        // self.sessionDidDeactivate = sessionDidDeactivate
        // self.sessionDidBecomeInactive = sessionDidBecomeInactive
        // self.sessionWatchStateDidChange = sessionWatchStateDidChange
        self.didReceiveMessage = didReceiveMessage
        // self.didReceiveMessageWithReplyHandler = didReceiveMessageWithReplyHandler
        // self.didReceiveMessageData = didReceiveMessageData
        // self.didReceiveMessageDataWithReplyHandler = didReceiveMessageDataWithReplyHandler

        super.init()
        self.session.delegate = self

        self.connect()
    }

    public func connect() {
        guard WCSession.isSupported() else {
            print("WCSession is not supported")
            return
        }
        session.activate()
    }

    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard activationState == .activated else { return }
        self.sessionDidActivate()
    }

    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        self.didReceiveMessage(message)
    }

    public func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        // self.didReceiveMessageWithReplyHandler(message, replyHandler)
    }

    public func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        // self.didReceiveMessageData(messageData)
    }

    public func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        // self.didReceiveMessageDataWithReplyHandler(messageData, replyHandler)
    }

    #if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        // self.sessionDidBecomeInactive()
    }

    public func sessionDidDeactivate(_ session: WCSession) {
        // self.sessionDidDeactivate()
        session.activate()
    }

    public func sessionWatchStateDidChange(_ session: WCSession) {
        // self.sessionWatchStateDidChange()
    }
    #endif
}
