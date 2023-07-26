//
//  Api.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import RoborockApi
import UIKit

extension Api {
    struct State: Equatable {
        var host: String?
        var connectivityState: ConnectivityState = .disconnected
        var segments: Segments?

        var sortedSegments: [Segment] {
            guard let segments = segments?.data else { return [] }
            return segments.sorted(by: { $0.name < $1.name })
        }

        var rooms: [Int] = []

        var state: VacuumState {
            guard let state = status?.vacuumState else {
                return VacuumState.unknown
            }
            return state
        }

        var isConnected: Bool {
            connectivityState == .connected
        }

        var inCleaning: Bool {
            guard let status = status else {
                return false
            }
            return status.inCleaning != 0
        }

        var inReturning: Bool {
            guard let status = status else {
                return false
            }
            return status.inReturning != 0
        }

        var battery: String {
            guard let status = status else {
                return "-"
            }
            return "\(status.battery)"
        }

        var cleanTime: String {
            guard let status = status else {
                return "-"
            }
            let minutes = String(format: "%02d", (status.cleanTime % 3600) / 60)
            let seconds = String(format: "%02d", (status.cleanTime % 3600) % 60)
            return "\(minutes):\(seconds)"
        }

        var cleanArea: String {
            guard let status = status else {
                return "-"
            }
            return String(format: "%.2f", Double(status.cleanArea) / 1000000)
        }

        #if os(iOS)
        var status: Status? {
            willSet {
                if self.inCleaning && newValue?.inCleaning == 0 {
                    ViewStore(Main.store.api).send(.resetRooms)
                }
            }
        }

        var mapData: MapData?
        var mapImage: UIImage?
        var pathImage: UIImage?
        var forbiddenZonesImage: UIImage?
        var robotImage: UIImage?
        var chargerImage: UIImage?
        var segmentLabelsImage: UIImage?

        var initialUpdateDone: Bool {
            mapImage != nil
                && pathImage != nil
                && forbiddenZonesImage != nil
                && robotImage != nil
                && chargerImage != nil
                && segmentLabelsImage != nil
        }
        #endif

        #if os(watchOS)
        var status: Status?
        #endif
    }
}
