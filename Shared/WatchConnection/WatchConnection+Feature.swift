//
//  WatchConnection+Feature.swift
//  Roborock
//
//  Created by Hack, Thomas on 23.07.21.
//

import Foundation

extension WatchConnection {
    @dynamicMemberLookup

    struct WatchConnectionFeatureState: Equatable {
        var watchConnection: WatchConnection.State
        var shared: Shared.State

        public subscript<T>(dynamicMember keyPath: WritableKeyPath<WatchConnection.State, T>) -> T {
            get { watchConnection[keyPath: keyPath] }
            set { watchConnection[keyPath: keyPath] = newValue }
        }

        public subscript<T>(dynamicMember keyPath: WritableKeyPath<Shared.State, T>) -> T {
            get { shared[keyPath: keyPath] }
            set { shared[keyPath: keyPath] = newValue }
        }
    }
}
