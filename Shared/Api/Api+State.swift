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
    @ObservableState
    struct State: Equatable {
        @Shared(.appStorage("host")) var host = ""
        @Shared(.inMemory("connectivityState")) var connectivityState: ConnectivityState = .disconnected
        @Presents var alert: AlertState<Action.Alert>?

        var isConnected: Bool {
            connectivityState == .connected
        }
        var status: RobotState?
        var segments: [Segment] = []
        var sortedSegments: [Segment] {
            segments.sorted(by: {
                guard let name1 = $0.name, let name2 = $1.name else { return $0.id < $1.id }
                return name1 < name2
            })
        }
        var selectedSegments: [Segment] = []
        var robotInfo: RobotInfo?
        var robotStatus: StateAttribute.StatusStateAttribute? {
            willSet {
                if robotStatus?.value == .cleaning, newValue?.value != .cleaning {
                    ViewStore(Main.store.api, observe: { $0 }).send(.resetRooms)
                }
            }
        }
        var batteryStatus: StateAttribute.BatteryStateAttribute?
        var fanSpeed: FanSpeedControlPreset = .off
        var waterUsage: WaterUsageControlPreset = .off
        var attachments: [StateAttribute.AttachmentStateAttribute] = []
        var isDustbinAttached = false
        var isWatertankAttached = false
        var isMopAttached = false

        var inCleaning: Bool {
            robotStatus?.value == .cleaning
        }

        var inReturning: Bool {
            robotStatus?.value == .returning
        }

        var batteryIcon: String {
            guard let status = batteryStatus else {
                return "exclamationmark.circle"
            }
            if status.flag == .charging {
                return "battery.100.bolt"
            } else if status.level < 25 {
                return "battery.25"
            } else {
                return "battery.100"
            }
        }

        var batteryValue: String {
            guard let status = batteryStatus else {
                return "-"
            }
            return "\(status.level)"
        }

        var cleanArea: Int?
        var cleanAreaReadable: String {
            cleanArea?.readableArea ?? "-"
        }
        var totalCleanArea: Int?
        var totalCleanAreaReadable: String {
            totalCleanArea?.readableArea ?? "-"
        }

        var cleanTime: Int?
        var cleanTimeReadable: String {
            cleanTime?.readableTime ?? "-"
        }
        var totalCleanTime: Int?
        var totalCleanTimeReadable: String {
            totalCleanTime?.readableTime ?? "-"
        }
        var totalCleanCount: Int?
        #if os(iOS) || os(tvOS) || os(visionOS)
        var mapImage: MapImage?
        var entityImages = MapImages(images: [])
        #endif
    }

    static let initialState = State()

    static let previewSegments = [
        Segment(id: "11", name: "Wohnzimmer"),
        Segment(id: "12", name: "Arbeitszimmer"),
        Segment(id: "13", name: "Schlafzimmer"),
        Segment(id: "14", name: "Küche")
    ]

    static let previewRobotInfo = RobotInfo(
        manufacturer: "Roborock",
        modelName: "S7",
        modelDetails: RobotInfo.ModelDetails(supportedAttachments: [.mop, .watertank]),
        implementation: "RoborockS7ValetudoRobot"
    )

    #if os(iOS) || os(tvOS) || os(visionOS)
    static let previewState = State(
        host: "roborock.friday.home",
        connectivityState: .connected,
        segments: previewSegments,
        selectedSegments: [],
        robotInfo: previewRobotInfo,
        robotStatus: StateAttribute.StatusStateAttribute(value: .docked, flag: .none),
        batteryStatus: StateAttribute.BatteryStateAttribute(level: 88, flag: .charging),
        fanSpeed: .max,
        waterUsage: .high,
        attachments: [
            StateAttribute.AttachmentStateAttribute(type: .watertank, attached: true),
            StateAttribute.AttachmentStateAttribute(type: .mop, attached: false)
        ],
        cleanArea: 296650,
        totalCleanArea: 93832650,
        cleanTime: 2472,
        totalCleanTime: 759065,
        totalCleanCount: 384,
        mapImage: .map(#imageLiteral(resourceName: "mapImagePreview")),
        entityImages: MapImages(images: [.charger(#imageLiteral(resourceName: "chargerImagePreview")), .robot(#imageLiteral(resourceName: "robotImagePreview"))])
    )
    #endif
    #if os(watchOS)
    static let previewState = State(
        host: "roborock.friday.home",
        connectivityState: .connected,
        segments: previewSegments,
        selectedSegments: [],
        robotInfo: previewRobotInfo,
        robotStatus: StateAttribute.StatusStateAttribute(value: .docked, flag: .none),
        batteryStatus: StateAttribute.BatteryStateAttribute(level: 88, flag: .charging),
        fanSpeed: .max,
        waterUsage: .high,
        attachments: [
            StateAttribute.AttachmentStateAttribute(type: .watertank, attached: true),
            StateAttribute.AttachmentStateAttribute(type: .mop, attached: false)
        ],
        cleanArea: 296650,
        totalCleanArea: 93832650,
        cleanTime: 2472,
        totalCleanTime: 759065,
        totalCleanCount: 384
    )
    #endif
}
