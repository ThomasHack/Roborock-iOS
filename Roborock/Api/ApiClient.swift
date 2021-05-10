//
//  ApiClient.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import SwiftUI
import ComposableArchitecture

struct ApiClient {
    var fetchCurrentStatus: (AnyHashable) -> Effect<Status, Failure>
    var fetchSegments: (AnyHashable) -> Effect<Segment, Failure>
    var fetchMap: (AnyHashable) -> Effect<Data, Failure>
    var startCleaningSegment: (AnyHashable, [Int]) -> Effect<Data, Failure>
    var stopCleaning: (AnyHashable) -> Effect<Data, Failure>
    var pauseCleaning: (AnyHashable) -> Effect<Data, Failure>
    var driveHome: (AnyHashable) -> Effect<Data, Failure>
    
    struct Failure: Error, Equatable {}
}

extension ApiClient {
    static let baseUrl = "http://roborock/api"
    static let live = ApiClient(
        fetchCurrentStatus: { id in
            let url = URL(string: "\(baseUrl)/current_status")!
            
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { data, _ in data }
                .decode(type: Status.self, decoder: jsonDecoder)
                .mapError { _ in Failure() }
                .eraseToEffect()
        }, fetchSegments: { id in
            let url = URL(string: "\(baseUrl)/segment_names")!
            
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { data, _ in data }
                .decode(type: Segment.self, decoder: jsonDecoder)
                .mapError { _ in Failure() }
                .eraseToEffect()
        }, fetchMap: { id in
            let url = URL(string: "\(baseUrl)/simple_map")!
            
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { data, _ in data }
                .mapError { _ in Failure() }
                .eraseToEffect()
        }, startCleaningSegment: { id, rooms in
            let url = URL(string: "\(baseUrl)/start_cleaning_segment")!
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            let requestData = [rooms, 1, 1] as [Any]
            request.httpBody = try! JSONSerialization.data(withJSONObject: requestData, options: .fragmentsAllowed)
            request.allHTTPHeaderFields = [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]

            return URLSession.shared.dataTaskPublisher(for: request)
                .map{ data, _ in data }
                .mapError{ _ in Failure() }
                .eraseToEffect()
        }, stopCleaning: { id in
            let url = URL(string: "\(baseUrl)/stop_cleaning")!
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"

            return URLSession.shared.dataTaskPublisher(for: request)
                .map { data, _ in data }
                .mapError { error in
                    print("data \(error.localizedDescription)")
                    return Failure()
                }
                .eraseToEffect()
        }, pauseCleaning: { id in
            let url = URL(string: "\(baseUrl)/pause_cleaning")!
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"

            return URLSession.shared.dataTaskPublisher(for: request)
                .map { data, _ in data }
                .mapError { _ in Failure() }
                .eraseToEffect()
        }, driveHome: { id in
            let url = URL(string: "\(baseUrl)/drive_home")!
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"

            return URLSession.shared.dataTaskPublisher(for: request)
                .map { data, _ in data }
                .mapError { _ in Failure() }
                .eraseToEffect()
        }
    )
}

private let jsonDecoder: JSONDecoder = {
  let d = JSONDecoder()
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd"
  formatter.calendar = Calendar(identifier: .iso8601)
  formatter.timeZone = TimeZone(secondsFromGMT: 0)
  formatter.locale = Locale(identifier: "en_US_POSIX")
  d.dateDecodingStrategy = .formatted(formatter)
  return d
}()
