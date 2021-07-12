//
//  ApiWebSocketClient.swift
//  Roborock
//
//  Created by Thomas Hack on 13.05.21.
//

import Foundation
import ComposableArchitecture
import Combine
import Network
import RoborockApi
import NWWebSocket

private var dependencies: [AnyHashable: Dependencies] = [:]
private struct Dependencies {
    let socket: NWWebSocket
    let delegate: ApiWebSocketDelegate
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
                dependencies[id] = Dependencies(socket: socket, delegate: delegate, subscriber: subscriber)
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
