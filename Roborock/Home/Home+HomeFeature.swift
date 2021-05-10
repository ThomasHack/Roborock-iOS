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
        var api: Api.State
        
        public subscript<T>(dynamicMember keyPath: WritableKeyPath<Home.State, T>) -> T {
            get { home[keyPath: keyPath] }
            set { home[keyPath: keyPath] = newValue }
        }

        public subscript<T>(dynamicMember keyPath: WritableKeyPath<Api.State, T>) -> T {
            get { api[keyPath: keyPath] }
            set { api[keyPath: keyPath] = newValue }
        }
    }
    
    static let previewState = HomeFeatureState(
        home: Home.State(rooms: []),
        api: Api.previewState
    )
}
