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
            print(#function)
            return Effect(value: .requestDataSync)

        case .watchSessionDidDeactivate:
            print(#function)

        case .didReceiveMessage(let message):
            print(#function)

        case .didReceiveMessageData(let data):
            print("\(#function)")
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
                print("responseWatchData")
            }

        case .watchSessionDidBecomeInactive:
            print(#function)

        case .watchSessionWatchStateDidChange:
            print(#function)

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
                print("Error: \(error.localizedDescription)")
            }
        }
        return .none
    }

    static let initialState = State()
}
