//
//  Shared.swift
//  Roborock
//
//  Created by Hack, Thomas on 06.07.21.
//

import ComposableArchitecture
import Foundation

struct Shared: ReducerProtocol {
    static let appGroupName = "group.thomashack.valetudo"
    static let hostDefaultsKeyName = "roborock.hostname"

    static let userDefaults = UserDefaults(suiteName: appGroupName)

    struct State: Equatable {
        var host: String? {
            didSet { userDefaults?.set(host, forKey: hostDefaultsKeyName) }
        }
    }

    enum Action {
        case updateHost(String)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateHost(let host):
                state.host = host
            }
            return .none
        }
    }

    static let initialState = State(
        host: userDefaults?.string(forKey: hostDefaultsKeyName)
    )
    static let previewState = State(
        host: "roborock.friday.home"
    )

    static let previewStore = Store(
        initialState: initialState,
        reducer: Shared()
    )
}
