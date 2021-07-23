//
//  Shared.swift
//  Roborock
//
//  Created by Hack, Thomas on 06.07.21.
//

import ComposableArchitecture
import Foundation

enum Shared {
    static let appGroupName = "group.thomashack.valetudo"
    static let hostDefaultsKeyName = "roborock.hostname"

    static let userDefaults = UserDefaults(suiteName: appGroupName)

    struct State: Equatable {
        var host: String? {
            didSet {
                userDefaults?.set(host, forKey: hostDefaultsKeyName)
            }
        }

        var showSettingsModal = false
    }

    static let initialState = State(
        host: userDefaults?.string(forKey: hostDefaultsKeyName)
    )

    enum Action {
        case updateHost(String)
        case showSettingsModal
        case hideSettingsModal
        case toggleSettingsModal(Bool)
    }

    typealias Environment = Main.Environment

    static let reducer = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .updateHost(let string):
            state.host = string
        case .showSettingsModal:
            state.showSettingsModal = true
        case .hideSettingsModal:
            state.showSettingsModal = false
        case .toggleSettingsModal(let toggle):
            state.showSettingsModal = toggle
        }
        return .none
    }
}
