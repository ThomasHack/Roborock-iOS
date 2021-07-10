//
//  StartCleaningIntentHandler.swift
//  StartCleaning
//
//  Created by Hack, Thomas on 08.07.21.
//

import Foundation
import Intents

class CleanRoomIntentHandler: NSObject, CleanRoomIntentHandling {
    private let availableRooms: [String] = ["Wohnzimmer", "Arbeitszimmer", "Schlafzimmer", "Badezimmer", "Flur", "Küche", "Vorrat", "Toilette"]

    func handle(intent: CleanRoomIntent, completion: @escaping (CleanRoomIntentResponse) -> Void) {
        guard let rooms = intent.rooms else {
            completion(CleanRoomIntentResponse(code: .failure, userActivity: nil))
            return
        }
        completion(CleanRoomIntentResponse.success(rooms: rooms))
    }

    func resolveRooms(for intent: CleanRoomIntent, with completion: @escaping ([INStringResolutionResult]) -> Void) {
        guard let rooms = intent.rooms else {
            completion([INStringResolutionResult.needsValue()])
            return
        }

        var result: [INStringResolutionResult] = []

        for room in rooms {
            if !availableRooms.contains(room) {
                result.append(INStringResolutionResult.needsValue())
            } else {
                result.append(INStringResolutionResult.success(with: room))
            }
        }
        completion(result)

    }

    func provideRoomsOptionsCollection(for intent: CleanRoomIntent, with completion: @escaping (INObjectCollection<NSString>?, Error?) -> Void) {
        completion(INObjectCollection(items: availableRooms.map { NSString(string: $0) }), nil)
    }
}
