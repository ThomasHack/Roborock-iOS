//
//  StartCleaningIntentHandler.swift
//  StartCleaning
//
//  Created by Hack, Thomas on 08.07.21.
//

import Foundation
import Intents
import Network
import RoborockApi
import SwiftUI

class CleanRoomIntentHandler: NSObject, CleanRoomIntentHandling {

    func handle(intent: CleanRoomIntent, completion: @escaping (CleanRoomIntentResponse) -> Void) {
        guard let rooms = intent.rooms else {
            completion(CleanRoomIntentResponse(code: .failure, userActivity: nil))
            return
        }
        cleanSegments(rooms: rooms) { result in
            switch result {
            case .success:
                completion(CleanRoomIntentResponse.success(rooms: rooms))
            case .failure:
                completion(CleanRoomIntentResponse(code: .failure, userActivity: nil))
            }
        }
    }

    func resolveRooms(for intent: CleanRoomIntent, with completion: @escaping ([RoomResolutionResult]) -> Void) {
        guard let rooms = intent.rooms else {
            completion([RoomResolutionResult.needsValue()])
            return
        }

        if rooms.isEmpty {
            completion([RoomResolutionResult.needsValue()])
            return
        }

        completion(rooms.map { (room) -> RoomResolutionResult in
            return RoomResolutionResult.success(with: room)
        })
    }

    func provideRoomsOptionsCollection(for intent: CleanRoomIntent, with completion: @escaping (INObjectCollection<Room>?, Error?) -> Void) {
        fetchSegments { result in
            switch result {
            case .success(let segments):
                let rooms = segments.map { Room(identifier: String($0.id), display: $0.name) }
                completion(INObjectCollection(items: rooms), nil)
            case .failure(let error):
                print("error: \(error.localizedDescription)")
                completion(nil, nil)
            }
        }
    }

    // MARK: - API methods

    enum ApiError: Error {
        case failedFetchSegments
        case failedCleanSegments
    }

    private let baseUrl = "http://roborock/api"

    private let jsonDecoder: JSONDecoder = {
        let decorder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        decorder.dateDecodingStrategy = .formatted(formatter)
        return decorder
    }()

    private func fetchSegments(completion: @escaping (Result<[Segment], Error>) -> Void) {
        let url = URL(string: "\(baseUrl)/segment_names")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            print("fetchSegments: \(String(describing: response))")
            if let data = data {
                do {
                    let segments = try JSONDecoder().decode(Segments.self, from: data)
                    completion(.success(segments.data))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            } else {
                completion(.failure(ApiError.failedFetchSegments))
            }
        }
        task.resume()
    }


    private func cleanSegments(rooms: [Room], completion: @escaping (Result<Bool, Error>) -> Void) {
        let segments = rooms.map { Int($0.identifier!) }
        let requestData = [segments, 1, 1] as [Any]
        let url = URL(string: "\(baseUrl)/start_cleaning_segment")!

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = try! JSONSerialization.data(withJSONObject: requestData, options: .fragmentsAllowed)
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let _ = data {
                completion(.success(true))
                return
            } else {
                completion(.failure(ApiError.failedCleanSegments))
                return
            }
        }
        task.resume()
    }
}
