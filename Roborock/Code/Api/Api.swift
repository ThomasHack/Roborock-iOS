//
//  Api.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import RoborockApi
import UIKit

struct ApiId: Hashable {}

enum ConnectivityState {
    case connected
    case connecting
    case disconnected
}

enum Api {
    typealias Environment = Main.Environment

    static let initialState = State()
    static let previewState = State()
}
