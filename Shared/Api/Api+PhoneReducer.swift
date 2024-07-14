//
//  Api+ReducerWatch.swift
//  Roborock
//
//  Created by Hack, Thomas on 29.02.24.
//

import ComposableArchitecture
import Foundation
import RoborockApi

extension Api {
    var phoneReducer: some ReducerOf<Api> {
        Reduce { state, action in
            switch action {
            case .update:
                return .merge(
                    .send(.fetchInfo),
                    .send(.fetchMap),
                    .send(.fetchSegments),
                    .send(.fetchState),
                    .send(.fetchCurrentStatistics),
                    .send(.fetchTotalStatistics)
                )
            case .subscribe:
                return .merge(
                    .send(.subscribeMap),
                    .send(.subscribeState)
                )
            case .unsubscribe:
                Task.cancel(id: EventClient.ID())
            case .toggleRoom(let segment):
                if let index = state.selectedSegments.firstIndex(of: segment) {
                    state.selectedSegments.remove(at: index)
                } else {
                    state.selectedSegments.append(segment)
                }
                return .send(.redrawMapImage)
            case .resetRooms:
                state.selectedSegments = []
                return .send(.fetchMap)
            case .fetchMap:
                return .run { send in
                    let mapData = try await restClient.fetchMap(RestClient.ID())
                    await send(.drawMapImage(mapData))
                    await send(.drawEntityImages(mapData))
                }
            case .subscribeMap:
                return .run { send in
                    let actions = try await self.eventClient.subscribe(EventClient.ID(), .mapStream)

                    await withThrowingTaskGroup(of: Void.self) { group in
                        for await action in actions {
                            group.addTask {
                                await send(.eventClient(action))
                            }
                        }
                    }
                }
                .cancellable(id: EventClientTask.map)
            case .drawMapImage(let mapData):
                let selectedSegments = state.selectedSegments.map { $0.id }
                return .run { send in
                    let image = try valetudoMapParser.parseMap(mapData, selectedSegments: selectedSegments)
                    await send(.updateMapImage(image))
                }
            case .redrawMapImage:
                let selectedSegments = state.selectedSegments.map { $0.id }
                return .run { send in
                    let image = try valetudoMapParser.drawMap(selectedSegments: selectedSegments)
                    await send(.updateMapImage(image))
                }
            case .drawEntityImages(let mapData):
                return .run { send in
                    let images = try valetudoMapParser.parseEntities(mapData)
                    await send(.updateEntityImages(images))
                }
            case .updateMapImage(let image):
                state.mapImage = image
            case .updateEntityImages(let images):
                state.entityImages = MapImages(images: images)
            case .eventClient(.didUpdateMap(let mapData)):
                return .merge(
                    .send(.drawMapImage(mapData)),
                    .send(.drawEntityImages(mapData))
                )
            default:
                break
            }
            return .none
        }
    }
}
