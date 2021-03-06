//
//  Home+HomeFeature.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import Foundation

extension Home {
    @dynamicMemberLookup

    struct HomeFeatureState: Equatable {
        var home: Home.State
        var settings: Settings.State
        var shared: Shared.State
        var api: Api.State

        var batteryIcon: String {
            guard let status = api.status else { return "exclamationmark.circle" }
            if status.state == 8 { // Charging
                return "battery.100.bolt"
            } else if status.battery < 25 {
                return "battery.25"
            } else {
                return "battery.100"
            }
        }

        public subscript<T>(dynamicMember keyPath: WritableKeyPath<Home.State, T>) -> T {
            get { home[keyPath: keyPath] }
            set { home[keyPath: keyPath] = newValue }
        }

        public subscript<T>(dynamicMember keyPath: WritableKeyPath<Settings.State, T>) -> T {
            get { settings[keyPath: keyPath] }
            set { settings[keyPath: keyPath] = newValue }
        }

        public subscript<T>(dynamicMember keyPath: WritableKeyPath<Shared.State, T>) -> T {
            get { shared[keyPath: keyPath] }
            set { shared[keyPath: keyPath] = newValue }
        }

        public subscript<T>(dynamicMember keyPath: WritableKeyPath<Api.State, T>) -> T {
            get { api[keyPath: keyPath] }
            set { api[keyPath: keyPath] = newValue }
        }
    }

    static let previewState = HomeFeatureState(
        home: Home.State(),
        settings: Settings.State(),
        shared: Shared.State(
            host: "http://preview.host",
            showSettingsModal: false
        ),
        api: Api.previewState
    )
}
