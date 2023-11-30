//
//  WatchKitSessionClient.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 21.07.21.
//  

import Combine
import ComposableArchitecture
import Foundation
import WatchConnectivity

extension DependencyValues {
    public var watchkitSessionClient: WatchKitSessionClient {
        get { self[WatchKitSessionClient.self] }
        set { self[WatchKitSessionClient.self] = newValue }
    }
}

public struct WatchKitSessionClient {
    // swiftlint:disable:next type_name
    public struct ID: Hashable, @unchecked Sendable {
        let rawValue: AnyHashable

        init<RawValue: Hashable & Sendable>(_ rawValue: RawValue) {
            self.rawValue = rawValue
        }

        public init() {
            struct RawValue: Hashable, Sendable {}
            self.rawValue = RawValue()
        }
    }

    @CasePathable
    public enum Action {
        case sessionDidActivate(WCSessionActivationState)
        case sessionDidDeactivate
        case sessionDidBecomeInactive
        case sessionWatchStateDidChange
        case didReceiveMessage([String: Any])
        case didReceiveMessageData(WCSessionData)
    }

    public enum Message: Equatable {
        struct Unknown: Error {}
        case string(String)
        case data(Data)
    }

    public var connect: @Sendable (ID) async throws -> AsyncStream<Action>
    public var sendMessage: @Sendable (ID, [String: Any]) async throws -> Void
    public var sendMessageWithReplyHandler: @Sendable (ID, [String: Any], @escaping ([String: Any]) -> Void) async throws -> Void
    public var sendMessageData: @Sendable (ID, Data) async throws -> Void
}

extension WatchKitSessionClient: DependencyKey {
    public static var liveValue: Self {
        return Self(
            connect: {
                try await WatchKitSessionActor.shared.connect(id: $0)
            },
            sendMessage: {
                try await WatchKitSessionActor.shared.sendMessage(id: $0, message: $1)
            },
            sendMessageWithReplyHandler: {
                try await WatchKitSessionActor.shared.sendMessageWithReplyHandler(id: $0, message: $1, replyHandler: $2)
            },
            sendMessageData: {
                try await WatchKitSessionActor.shared.sendMessageData(id: $0, message: $1)
            }
        )

        final actor WatchKitSessionActor: GlobalActor {
            typealias Dependencies = (session: WCSession, delegate: WatchKitSessionDelegate)

            static let shared = WatchKitSessionActor()

            var dependencies: [ID: Dependencies] = [:]

            func connect(id: ID) throws -> AsyncStream<Action> {
                let delegate = WatchKitSessionDelegate()
                let session = WCSession.default

                struct NotSupported: Error {}

                guard WCSession.isSupported() else {
                    print("WCSession is not supported")
                    throw NotSupported()
                }
                session.delegate = delegate
                defer {  }
                session.activate()

                // swiftlint:disable:next implicitly_unwrapped_optional
                var continuation: AsyncStream<Action>.Continuation!
                let stream = AsyncStream<Action> {
                    $0.onTermination = { _ in
                        Task { await self.removeDependencies(id: id) }
                    }
                    continuation = $0
                }
                delegate.continuation = continuation
                self.dependencies[id] = (session, delegate)
                return stream
            }

            func sendMessage(id: ID, message: [String: Any]) throws {
                try self.session(id: id).sendMessage(message, replyHandler: nil)
            }

            func sendMessageWithReplyHandler(id: ID, message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) throws {
                try self.session(id: id).sendMessage(message, replyHandler: replyHandler)
            }

            func sendMessageData(id: ID, message: Data) throws {
                try self.session(id: id).sendMessageData(message, replyHandler: nil)
            }

            func sendMessageDataWithReplyHandler(id: ID, message: Data, replyHandler: @escaping (Data) -> Void) async throws {
                try self.session(id: id).sendMessageData(message, replyHandler: replyHandler)
            }

            private func session(id: ID) throws -> WCSession {
                guard let dependencies = self.dependencies[id]?.session else {
                    struct Closed: Error {}
                    throw Closed()
                }
                return dependencies
            }

            private func removeDependencies(id: ID) {
                self.dependencies[id] = nil
            }
        }
    }
}
