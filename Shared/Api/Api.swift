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

struct Api: ReducerProtocol {
    @Dependency(\.restClient) var restClient
    @Dependency(\.websocketClient) var websocketClient
    #if os(iOS)
    @Dependency(\.rrFileParser) var rrFileParser
    #endif

    static let initialState = State()

    static let previewState = State(connectivityState: .connected,
                                    segments: Segments(segment: [
                                        Segment(id: 1, name: "Wohnzimmer"),
                                        Segment(id: 2, name: "Arbeitszimmer"),
                                        Segment(id: 3, name: "Schlafzimmer"),
                                        Segment(id: 4, name: "Küche")
                                    ]),
                                    rooms: [],
                                    status: Status(state: 8,
                                                   otaState: "",
                                                   messageVersion: 1,
                                                   battery: 86,
                                                   cleanTime: 60,
                                                   cleanArea: 10,
                                                   errorCode: 0,
                                                   mapPresent: 1,
                                                   inCleaning: 0,
                                                   inReturning: 0,
                                                   inFreshState: 1,
                                                   waterBoxStatus: 0,
                                                   fanPower: 101,
                                                   dndEnabled: 0,
                                                   mapStatus: 1,
                                                   mainBrushLife: 100,
                                                   sideBrushLife: 200,
                                                   filterLife: 300,
                                                   stateHumanReadable: "Charging",
                                                   model: "roborock.s5",
                                                   errorHumanReadable: ""
                                                  )
    )

    static let previewStore = Store(
        initialState: initialState,
        reducer: Api()
    )
}
