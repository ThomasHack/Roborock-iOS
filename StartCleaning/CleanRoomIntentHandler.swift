//
//  StartCleaningIntentHandler.swift
//  StartCleaning
//
//  Created by Hack, Thomas on 08.07.21.
//

import Foundation
import Intents

class CleanRoomIntentHandler: NSObject, CleanRoomIntentHandling {
    private let availableRooms: [Room] = [
        Room(identifier: "16", display: "Arbeitszimmer"),
        Room(identifier: "17", display: "Wohnzimmer"),
        Room(identifier: "18", display: "Vorrat"),
        Room(identifier: "19", display: "Badezimmer"),
        Room(identifier: "21", display: "Schlafzimmer"),
        Room(identifier: "22", display: "Flur"),
        Room(identifier: "23", display: "Küche"),
    ]

    func handle(intent: CleanRoomIntent, completion: @escaping (CleanRoomIntentResponse) -> Void) {
        guard let rooms = intent.rooms else {
            completion(CleanRoomIntentResponse(code: .failure, userActivity: nil))
            return
        }
        completion(CleanRoomIntentResponse.success(rooms: rooms))
    }

    func resolveRooms(for intent: CleanRoomIntent, with completion: @escaping ([RoomResolutionResult]) -> Void) {
        guard let rooms = intent.rooms else {
            completion([RoomResolutionResult.needsValue()])
            return
        }

        var result: [RoomResolutionResult] = []

        for room in rooms {
            if !availableRooms.contains(room) {
                result.append(RoomResolutionResult.needsValue())
            } else {
                result.append(RoomResolutionResult.success(with: room))
            }
        }
        completion(result)
    }

    func provideRoomsOptionsCollection(for intent: CleanRoomIntent, with completion: @escaping (INObjectCollection<Room>?, Error?) -> Void) {
        completion(INObjectCollection(items: availableRooms), nil)
    }
}
