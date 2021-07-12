//
//  ApiDelegate.swift
//  Roborock
//
//  Created by Thomas Hack on 13.05.21.
//

import Foundation
import Network
import NWWebSocket

public class ApiWebSocketDelegate: WebSocketConnectionDelegate {

    let didConnect: () -> Void
    let didDisconnect: () -> Void
    let didReceiveWebSocketEvent: (ApiWebSocketEvent) -> Void
    let didUpdateStatus: (Status) -> Void

    public init(
        didConnect: @escaping() -> Void,
        didDisconnect: @escaping() -> Void,
        didReceiveWebSocketEvent: @escaping (ApiWebSocketEvent) -> Void,
        didUpdateStatus: @escaping (Status) -> Void
    ) {
        self.didConnect = didConnect
        self.didDisconnect = didDisconnect
        self.didReceiveWebSocketEvent = didReceiveWebSocketEvent
        self.didUpdateStatus = didUpdateStatus
    }

    public func webSocketDidConnect(connection: WebSocketConnection) {
        self.didConnect()
    }

    public func webSocketDidDisconnect(connection: WebSocketConnection, closeCode: NWProtocolWebSocket.CloseCode, reason: Data?) {
        self.didDisconnect()
    }

    public func webSocketViabilityDidChange(connection: WebSocketConnection, isViable: Bool) {

    }

    public func webSocketDidAttemptBetterPathMigration(result: Result<WebSocketConnection, NWError>) {

    }

    public func webSocketDidReceiveError(connection: WebSocketConnection, error: NWError) {
        self.didReceiveWebSocketEvent(.error(error as NSError?))
    }

    public func webSocketDidReceivePong(connection: WebSocketConnection) {
        self.didReceiveWebSocketEvent(.pong)
    }

    public func webSocketDidReceiveMessage(connection: WebSocketConnection, string: String) {
        self.didReceiveText(string)
    }

    public func webSocketDidReceiveMessage(connection: WebSocketConnection, data: Data) {
        self.didReceiveWebSocketEvent(.binary(data))
    }

    private func didReceiveText(_ string: String) {
        guard let data = string.data(using: .utf8, allowLossyConversion: true) else { return }
        do {
            let response = try JSONDecoder().decode(Response.self, from: data)
            switch response {
            case .status(let status):
                self.didUpdateStatus(status)
            default:
                break
            }
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
}
