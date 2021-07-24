//
//  WatchConnection.swift
//  Roborock
//
//  Created by Hack, Thomas on 23.07.21.
//

import ComposableArchitecture
import Foundation

enum WatchConnection {
    struct State: Equatable {}

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

    typealias Environment = Main.Environment

    static let reducer = Reducer<WatchConnectionFeatureState, Action, Environment> { state, action, environment in
        switch action {
        case .connect:
            return environment.watchkitSessionClient.connect(WatchKitId())
                .receive(on: environment.mainQueue)
                .eraseToEffect()

        case .watchSessionDidActivate:
            return Effect(value: .requestDataSync)

        case .watchSessionDidDeactivate:
            break

        case .didReceiveMessage(let message):
            break

        case .didReceiveMessageData(let data):
            switch data {
            case .requestData(let response):
                switch response.action {
                case .synchronizeUserDefaults:
                    guard let host = state.shared.host else { return .none }
                    let requestData = WCSessionAppResponseData(host: host)
                    return Effect(value: .sendMessageData(WCSessionData.responseAppData(requestData)))
                        .receive(on: environment.mainQueue)
                        .eraseToEffect()
                }
            case .responseAppData(let response):
                state.shared.host = response.host

            case .responseWatchData(let watchData):
                break
            }

        case .watchSessionDidBecomeInactive:
            break

        case .watchSessionWatchStateDidChange:
            break

        case .requestDataSync:
            let requestData = WCSessionRequestData(action: .synchronizeUserDefaults)
            return Effect(value: .sendMessageData(WCSessionData.requestData(requestData)))
                .receive(on: environment.mainQueue)
                .eraseToEffect()

        case .resetData:
            state.shared.host = nil

        case .sendMessageData(let data):
            do {
                return try environment.watchkitSessionClient.sendMessageData(WatchKitId(), data)
            } catch {
                print(error.localizedDescription)
            }
        }
        return .none
    }

    static let initialState = State()
}
