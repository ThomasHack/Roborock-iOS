//
//  WatchConnection.swift
//  Roborock
//
//  Created by Hack, Thomas on 23.07.21.
//

import ComposableArchitecture
import Foundation

struct WatchConnection: ReducerProtocol {
    @Dependency(\.watchkitSessionClient) var watchkitSessionClient

    struct State: Equatable {
        var host: String?
    }

    enum Action {
        case connect
        case watchSessionDidActivate
        case watchSessionDidDeactivate
        case watchSessionDidBecomeInactive
        case watchSessionWatchStateDidChange
        case didReceiveMessage([String: Any])
        case didReceiveMessageData(WCSessionData)
        case requestDataSync
        case resetData
        case sendMessageData(WCSessionData)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .connect:
                return watchkitSessionClient.connect(WatchKitId())
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()

            case .watchSessionDidActivate:
                return EffectTask(value: .requestDataSync)

            case .watchSessionDidDeactivate:
                break

            case .didReceiveMessage:
                break

            case .didReceiveMessageData(let data):
                switch data {
                case .requestData(let response):
                    switch response.action {
                    case .synchronizeUserDefaults:
                        guard let host = state.host else { return .none }
                        let requestData = WCSessionAppResponseData(host: host)
                        return EffectTask(value: .sendMessageData(WCSessionData.responseAppData(requestData)))
                            .receive(on: DispatchQueue.main)
                            .eraseToEffect()
                    }
                case .responseAppData(let response):
                    state.host = response.host

                case .responseWatchData:
                    break
                }

            case .watchSessionDidBecomeInactive:
                break

            case .watchSessionWatchStateDidChange:
                break

            case .requestDataSync:
                let requestData = WCSessionRequestData(action: .synchronizeUserDefaults)
                return EffectTask(value: .sendMessageData(WCSessionData.requestData(requestData)))
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()

            case .resetData:
                state.host = nil

            case .sendMessageData(let data):
                do {
                    return try watchkitSessionClient.sendMessageData(WatchKitId(), data)
                } catch {
                    print(error.localizedDescription)
                }
            }
            return .none
        }
    }

    static let initialState = State(
        host: UserDefaultsHelper.host
    )
}
