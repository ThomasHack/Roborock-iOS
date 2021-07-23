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
    let subscriber: Effect<Main.Action, Never>.Subscriber
}

struct WatchKitSessionClient {
    var connect: (AnyHashable) -> Effect<Main.Action, Never>
    var disconnect: (AnyHashable) -> Effect<Main.Action, Never>
    var sendMessage: (AnyHashable, [String: Any]) -> Effect<Main.Action, Never>
    var sendMessageWithReplyHandler: (AnyHashable, [String: Any], @escaping ([String: Any]) -> Void) -> Effect<Main.Action, Never>
    var sendMessageData: (AnyHashable, Data) -> Effect<Main.Action, Never>
    var sendMessageDataWithReplyHandler: (AnyHashable, Data, @escaping (Data) -> Void) -> Effect<Main.Action, Never>
}

extension WatchKitSessionClient {
    static let live = WatchKitSessionClient(
        connect: { id in
            .run { subscriber in
                let delegate = WatchkitSessionDelegate(
                    sessionDidActivate: {
                        subscriber.send(.watchSessionDidActivate)
                    },
                    didReceiveMessage: {
                        subscriber.send(.didReceiveMessage($0))
                    }/*,
                    didReceiveMessageWithReplyHandler: { message, replyHandler in
                        subscriber.send(.didReceiveMessageWithReplyHandler(message, { response in
                            replyHandler(response)
                        }))
                    },
                    didReceiveMessageData: {
                        subscriber.send(.didReceiveMessageData($0))
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
        sendMessageData: { id, data in
            .run { _ in
                dependencies[id]?.session.sendMessageData(data, replyHandler: nil, errorHandler: nil)
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
