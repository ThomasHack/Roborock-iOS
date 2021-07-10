//
//  IntentHandler.swift
//  StartCleaning
//
//  Created by Hack, Thomas on 08.07.21.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        guard intent is CleanRoomIntent else {
            fatalError("Unhandled Intent error : \(intent)")
        }
        return CleanRoomIntentHandler()
    }
}
