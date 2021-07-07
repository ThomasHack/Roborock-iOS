//
//  Settings+SettingsFeature.swift
//  Roborock
//
//  Created by Hack, Thomas on 06.07.21.
//
import Foundation

extension Settings {
    @dynamicMemberLookup
    struct SettingsFeatureState: Equatable {
        var settings: Settings.State
        var shared: Shared.State
        var api: Api.State

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

    static let previewState = SettingsFeatureState(
        settings: Settings.State(),
        shared: Shared.State(
            host: "http://preview.host",
            showSettingsModal: false
        ),
        api: Api.previewState
    )
}
