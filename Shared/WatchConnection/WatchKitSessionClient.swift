//
//  WatchKitSessionClient.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 21.07.21.
//  swiftlint:disable weak_delegate

import Combine
import ComposableArchitecture
import Foundation
import WatchConnectivity

private var dependencies: [AnyHashable: Dependencies] = [:]

private struct Dependencies {
    let session: WCSession
    let delegate: WatchkitSessionDelegate
    let subscriber: Effect<WatchConnection.Action, Never>.Subscriber
}

struct WatchKitSessionClient {
    var connect: (AnyHashable) -> Effect<WatchConnection.Action, Never>
    var disconnect: (AnyHashable) -> Effect<WatchConnection.Action, Never>
    var sendMessage: (AnyHashable, [String: Any]) -> Effect<WatchConnection.Action, Never>
    var sendMessageWithReplyHandler: (AnyHashable, [String: Any], @escaping ([String: Any]) -> Void) -> Effect<WatchConnection.Action, Never>
    var sendMessageData: (AnyHashable, WCSessionData) throws -> Effect<WatchConnection.Action, Never>
    var sendMessageDataWithReplyHandler: (AnyHashable, Data, @escaping (Data) -> Void) -> Effect<WatchConnection.Action, Never>
}

extension WatchKitSessionClient {
    static let live = WatchKitSessionClient(
        connect: { id in
            .run { subscriber in
                let delegate = WatchkitSessionDelegate(
                    sessionDidActivate: {
                        subscriber.send(.watchSessionDidActivate)
                    },
                    sessionDidDeactivate: {
                        subscriber.send(.watchSessionDidDeactivate)
                    },
                    sessionDidBecomeInactive: {
                        subscriber.send(.watchSessionDidBecomeInactive)
                    },
                    sessionWatchStateDidChange: {
                        subscriber.send(.watchSessionWatchStateDidChange)
                    },
                    didReceiveMessage: {
                        subscriber.send(.didReceiveMessage($0))
                    },
                    didReceiveMessageData: {
                        subscriber.send(.didReceiveMessageData($0))
                    }/*,
                    didReceiveMessageWithReplyHandler: { message, replyHandler in
                        subscriber.send(.didReceiveMessageWithReplyHandler(message, { response in
                            replyHandler(response)
                        }))
                    },
                    didReceiveMessageDataWithReplyHandler: { message, replyHandler in
                        subscriber.send(.didReceiveMessageDataWithReplyHandler(message, { response in
                            replyHandler(response)
                        }))
                    }*/
                )
                let session = WCSession.default
                dependencies[id] = Dependencies(session: session, delegate: delegate, subscriber: subscriber)
                return AnyCancellable {
                    dependencies[id]?.subscriber.send(completion: .finished)
                    dependencies[id] = nil
                }
            }
        },
        disconnect: { id in
            .run { _ in
                dependencies[id]?.subscriber.send(.watchSessionDidDeactivate)
                return AnyCancellable {
                    dependencies[id]?.subscriber.send(completion: .finished)
                    dependencies[id] = nil
                }
            }
        },
        sendMessage: { id, message in
            .run { _ in
                dependencies[id]?.session.sendMessage(message, replyHandler: nil, errorHandler: nil)
                return AnyCancellable {}
            }
        },
        sendMessageWithReplyHandler: { id, message, replyHandler in
            .run { _ in
                dependencies[id]?.session.sendMessage(message,
                                                      replyHandler: { response in
                    replyHandler(response)
                    // subscriber.send(.didReceiveMessage(response))
                }, errorHandler: { error in
                    print("Error: \(error.localizedDescription)")
                })
                return AnyCancellable {}
            }
        },
        sendMessageData: { id, sessionData in
            .run { _ in
                do {
                    let data = try JSONEncoder().encode(sessionData)
                    dependencies[id]?.session.sendMessageData(data, replyHandler: nil, errorHandler: nil)
                } catch {
                    assertionFailure("")
                }
                return AnyCancellable {}
            }
        },
        sendMessageDataWithReplyHandler: { id, data, replyHandler in
            .run { _ in
                dependencies[id]?.session.sendMessageData(data,
                                                          replyHandler: { response in
                    replyHandler(response)
                    // subscriber.send(.didReceiveMessageData(response))
                }, errorHandler: { error in
                    print("Error: \(error.localizedDescription)")
                })
                return AnyCancellable {}
            }
        }
    )
}
