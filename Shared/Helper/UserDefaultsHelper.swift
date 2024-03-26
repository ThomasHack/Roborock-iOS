//
//  UserDefaultsHelper.swift
//  Roborock
//
//  Created by Hack, Thomas on 26.07.23.
//

import Foundation

enum UserDefaultsHelper {
    private static let suiteName = "group.thomashack.valetudo"
    private static let hostDefaultsKeyName = "roborock.hostname"
    private static let userDefaults = UserDefaults(suiteName: suiteName)

    static var host: String? {
        userDefaults?.string(forKey: hostDefaultsKeyName)
    }

    static func setHost(_ host: String?) {
        if let host = host {
            userDefaults?.setValue(host, forKey: hostDefaultsKeyName)
        }
    }
}
