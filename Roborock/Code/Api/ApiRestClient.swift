//
//  ApiClient.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import Combine
import ComposableArchitecture
import RoborockApi
import SwiftUI

struct ApiRestClient {
    var fetchSegments: (AnyHashable) -> Effect<Segments, Failure>
    var startCleaningSegment: (AnyHashable, [Int]) -> Effect<Data, Failure>
    var stopCleaning: (AnyHashable) -> Effect<Data, Failure>
    var pauseCleaning: (AnyHashable) -> Effect<Data, Failure>
    var driveHome: (AnyHashable) -> Effect<Data, Failure>
    var setFanspeed: (AnyHashable, Int) -> Effect<Data, Failure>

    struct Failure: Error, Equatable {}
}

extension ApiRestClient {
    static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()

    static let baseUrl = "http://roborock.home/api"
    static let live = ApiRestClient(
        fetchSegments: { _ in
        guard let url = URL(string: "\(baseUrl)/segment_names") else { return .none }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map { data, _ in data }
            .decode(type: Segments.self, decoder: jsonDecoder)
            .mapError { _ in Failure() }
            .eraseToEffect()
    },
        startCleaningSegment: { _, rooms in
        guard let url = URL(string: "\(baseUrl)/start_cleaning_segment") else { return .none }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        let requestData = [rooms, 1, 1] as [Any]

        do {
            let httpBody = try JSONSerialization.data(withJSONObject: requestData, options: .fragmentsAllowed)
            request.httpBody = httpBody
            request.allHTTPHeaderFields = [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]

            return URLSession.shared.dataTaskPublisher(for: request)
                .map { data, _ in data }
                .mapError { _ in Failure() }
                .eraseToEffect()
        } catch {
            return .none
        }
    },
        stopCleaning: { _ in
        guard let url = URL(string: "\(baseUrl)/stop_cleaning") else { return .none }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { data, _ in data }
            .mapError { error in
                print("data \(error.localizedDescription)")
                return Failure()
            }
            .eraseToEffect()
    },
        pauseCleaning: { _ in
        guard let url = URL(string: "\(baseUrl)/pause_cleaning") else { return .none }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { data, _ in data }
            .mapError { _ in Failure() }
            .eraseToEffect()
    },
        driveHome: { _ in
        guard let url = URL(string: "\(baseUrl)/drive_home") else { return .none }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { data, _ in data }
            .mapError { _ in Failure() }
            .eraseToEffect()
    },
        setFanspeed: { _, fanspeed in
        guard let url = URL(string: "\(baseUrl)/fanspeed") else { return .none }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let requestData = ["speed": fanspeed]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestData, options: .fragmentsAllowed)
            request.allHTTPHeaderFields = [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]

            return URLSession.shared.dataTaskPublisher(for: request)
                .map { data, _ in data }
                .mapError { _ in Failure() }
                .eraseToEffect()
        } catch {
            return .none
        }

    }
    )
}
