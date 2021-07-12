//
//  IntentHandler.swift
//  StartCleaning
//
//  Created by Hack, Thomas on 08.07.21.
//

import Intents

class IntentHandler: INExtension {

    override func handler(for intent: INIntent) -> Any {
        guard intent is CleanRoomIntent else {
            fatalError("Unhandled Intent error : \(intent)")
        }
        return CleanRoomIntentHandler()
    }
}
