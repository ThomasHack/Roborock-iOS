//
//  ApiWebSocketClient.swift
//  Roborock
//
//  Created by Thomas Hack on 13.05.21.
//

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
    let subscriber: EffectTask<Api.Action>.Subscriber
}

var tlsParameters: NWParameters {
    let options = NWProtocolTLS.Options()
    let securityOptions = options.securityProtocolOptions
    sec_protocol_options_set_verify_block(securityOptions, { _, sec_trust, completionHandler in
        // Load local certificate
        guard let certificatePath = Bundle.main.path(forResource: "friday", ofType: "cer"),
              let pinnedCertificateData = NSData(contentsOfFile: certificatePath) else {
            print("Could not load local certificate")
            completionHandler(false)
            return
        }

        let trust = sec_trust_copy_ref(sec_trust).takeRetainedValue()

        // Load remote certificate chain
        guard let remoteCertificateChain = SecTrustCopyCertificateChain(trust) as? [SecCertificate] else {
            print("Could not load remote certificate chain")
            completionHandler(false)
            return
        }

        // Map remote certificate chain
        let remoteCertificatesData = Set(
            remoteCertificateChain.map { SecCertificateCopyData($0) as NSData }
        )

        // Check if remote chain contains local certificate
        if remoteCertificatesData.contains(pinnedCertificateData) {
            completionHandler(true)
        } else {
            print("Certificate does not match")
            completionHandler(false)
            return
        }
    }, .main)
    return NWParameters(tls: options)
}

struct ApiWebSocketClient {
    var connect: (AnyHashable, URL) -> EffectTask<Api.Action>
    var disconnect: (AnyHashable) -> EffectTask<Api.Action>
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
                    },
                    didUpdateStatus: {
                        subscriber.send(.didUpdateStatus($0 as Status))
                    }
                )
                let socket = NWWebSocket(url: url, connectAutomatically: true, tlsParamters: tlsParameters)
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
            .run { _ in
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
