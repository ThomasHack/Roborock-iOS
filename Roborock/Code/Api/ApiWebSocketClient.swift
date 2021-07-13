//
//  ApiWebSocketClient.swift
//  Roborock
//
//  Created by Thomas Hack on 13.05.21.
//  swiftlint:disable weak_delegate

import Combine
import ComposableArchitecture
import Foundation
import Network
import NWWebSocket
import RoborockApi

private var dependencies: [AnyHashable: Dependencies] = [:]
private struct Dependencies {
    let delegate: ApiWebSocketDelegate
    let socket: NWWebSocket
    let subscriber: Effect<Api.Action, Never>.Subscriber
}

struct ApiWebSocketClient {
    var connect: (AnyHashable, URL) -> Effect<Api.Action, Never>
    var disconnect: (AnyHashable) -> Effect<Api.Action, Never>
}

extension ApiWebSocketClient {
    static let live = ApiWebSocketClient(
        connect: { id, url in
            .run { subscriber in
                let delegate = ApiWebSocketDelegate(
                    didConnect: {
                        subscriber.send(.didConnect)
                    },
                    didDisconnect: {
                        subscriber.send(.didDisconnect)
                    },
                    didReceiveWebSocketEvent: {
                        subscriber.send(.didReceiveWebSocketEvent($0 as ApiWebSocketEvent))
                    }, didUpdateStatus: {
                        subscriber.send(.didUpdateStatus($0 as Status))
                    }
                )
                let socket = NWWebSocket(url: url)
                socket.delegate = delegate
                socket.connect()
                dependencies[id] = Dependencies(delegate: delegate, socket: socket, subscriber: subscriber)
                return AnyCancellable {
                    dependencies[id]?.subscriber.send(completion: .finished)
                    dependencies[id] = nil
                }
            }
        },
        disconnect: { id in
            .run { subscriber in
                dependencies[id]?.socket.disconnect()
                dependencies[id]?.subscriber.send(.didDisconnect)
                return AnyCancellable {
                    dependencies[id]?.subscriber.send(completion: .finished)
                    dependencies[id] = nil
                }
            }
        }
    )
}
