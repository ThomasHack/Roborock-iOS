//
//  Api.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import RoborockApi
import UIKit

@Reducer
struct Api {
    @Dependency(\.restClient) var restClient
    @Dependency(\.eventClient) var eventClient
    #if os(iOS) || os(tvOS) || os(visionOS)
    @Dependency(\.valetudoMapParser) var valetudoMapParser
    #endif

    enum EventClientTask: Hashable {
        case map
        case update
        case subscribe
        case stateAttributes
    }

    var body: some Reducer<State, Action> {
        #if os(iOS) || os(tvOS) || os(visionOS)
        phoneReducer
        #endif
        #if os(watchOS)
        watchReducer
        #endif
        Reduce { state, action in
            switch action {
            case .connect:
                guard !state.host.isEmpty, let url = URL(string: "https://\(state.host)") else { return .none }
                state.connectivityState = .connecting
                return .run { send in
                    try await restClient.connect(RestClient.ID(), url)
                    try await eventClient.connect(EventClient.ID(), url)
                    await send(.update)
                    await send(.subscribe)
                }
            case .disconnect:
                return .send(.unsubscribe)
            case .didConnect:
                state.connectivityState = .connected
            case .didDisconnect:
                state.connectivityState = .disconnected
                return .send(.resetState)
            case .fetchState:
                return .run { send in
                    let state = try await restClient.fetchStateAttributes(RestClient.ID())
                    return await send(.updateState(state))
                } catch: { error, send in
                    await send(.alert(.presented(.apiError(error.localizedDescription))))
                }
            case .alert(.presented(.apiError(let description))):
                state.connectivityState = .disconnected
                state.alert = AlertState { TextState(description) }
            case .subscribeState:
                return .run { send in
                    let actions = try await self.eventClient.subscribe(EventClient.ID(), .stateAttributesStream)

                    await withThrowingTaskGroup(of: Void.self) { group in
                        for await action in actions {
                            group.addTask {
                                await send(.eventClient(action))
                            }
                        }
                    }
                }
                .cancellable(id: EventClientTask.stateAttributes)
            case .updateState(let status):
                state.attachments = []
                for attribute in status {
                    switch attribute.data {
                    case let .attachment(attachment):
                        state.attachments.append(attachment)
                        if attachment.type == .dustbin {
                            state.isDustbinAttached = attachment.attached
                        }
                        if attachment.type == .mop {
                            state.isMopAttached = attachment.attached
                        }
                        if attachment.type == .watertank {
                            state.isWatertankAttached = attachment.attached
                        }
                    case let .battery(status):
                        state.batteryStatus = status
                    case let .preset(preset):
                        if preset.type == .fanSpeed {
                            state.fanSpeed = FanSpeedControlPreset(rawValue: preset.value.rawValue) ?? .off
                        }
                        if preset.type == .waterGrade {
                            state.waterUsage = WaterUsageControlPreset(rawValue: preset.value.rawValue) ?? .off
                        }
                        if preset.type == .operationMode {
                            // state.operationMode = preset.value
                        }
                    case let .status(status):
                        state.robotStatus = status
                    case let .consumable(status):
                        print(status)
                    }
                }
            case .fetchInfo:
                return .run { send in
                    let robotInfo = try await restClient.fetchInfo(RestClient.ID())
                    await send(.fetchInfoResponse(robotInfo))
                } catch: { error, send in
                    await send(.alert(.presented(.apiError(error.localizedDescription))))
                }
            case .fetchInfoResponse(let robotInfo):
                state.robotInfo = robotInfo
            case .fetchCurrentStatistics:
                return .run { send in
                    let statistics = try await restClient.fetchCurrentStatistics(RestClient.ID())
                    await send(.fetchCurrentStatisticsResponse(statistics))
                } catch: { error, send in
                    await send(.alert(.presented(.apiError(error.localizedDescription))))
                }
            case .fetchCurrentStatisticsResponse(let statistics):
                for statistic in statistics {
                    switch statistic.type {
                    case .area:
                        state.cleanArea = statistic.value
                    case .time:
                        state.cleanTime = statistic.value
                    default:
                        break
                    }
                }
            case .fetchTotalStatistics:
                return .run { send in
                    let statistics = try await restClient.fetchTotalStatistics(RestClient.ID())
                    await send(.fetchTotalStatisticsResponse(statistics))
                } catch: { error, send in
                    await send(.alert(.presented(.apiError(error.localizedDescription))))
                }
            case .fetchTotalStatisticsResponse(let statistics):
                for statistic in statistics {
                    switch statistic.type {
                    case .area:
                        state.totalCleanArea = statistic.value
                    case .time:
                        state.totalCleanTime = statistic.value
                    case .count:
                        state.totalCleanCount = statistic.value
                    }
                }
            case .fetchSegments:
                return .run { send in
                    let segments = try await restClient.fetchSegments(RestClient.ID())
                    await send(.fetchSegmentsResponse(segments))
                } catch: { error, send in
                    await send(.alert(.presented(.apiError(error.localizedDescription))))
                }
            case .fetchSegmentsResponse(let segments):
                state.segments = segments
            case .startCleaningSegment:
                let selectedSegments = state.selectedSegments
                return .run { _ in
                    _ = try await restClient.cleanSegments(RestClient.ID(), selectedSegments)
                } catch: { error, send in
                    await send(.alert(.presented(.apiError(error.localizedDescription))))
                }
            case .stopCleaning:
                return .run { send in
                    _ = try await restClient.stopCleaning(RestClient.ID())
                    await send(.resetRooms)
                } catch: { error, send in
                    await send(.alert(.presented(.apiError(error.localizedDescription))))
                }
            case .pauseCleaning:
                return .run { _ in
                    _ = try await restClient.pauseCleaning(RestClient.ID())
                } catch: { error, send in
                    await send(.alert(.presented(.apiError(error.localizedDescription))))
                }
            case .driveHome:
                return .run { _ in
                    _ = try await restClient.driveHome(RestClient.ID())
                } catch: { error, send in
                    await send(.alert(.presented(.apiError(error.localizedDescription))))
                }
            case let .controlFanSpeed(preset):
                return .run { send in
                    _ = try await restClient.controlFanSpeed(RestClient.ID(), preset)
                    return await send(.fetchState)
                } catch: { error, send in
                    await send(.alert(.presented(.apiError(error.localizedDescription))))
                }
            case let .controlWaterUsage(preset):
                return .run { send in
                    _ = try await restClient.controlWaterUsage(RestClient.ID(), preset)
                    return await send(.fetchState)
                } catch: { error, send in
                    await send(.alert(.presented(.apiError(error.localizedDescription))))
                }
            case .resetState:
                state.attachments = []
                state.selectedSegments = []
                state.robotStatus = nil
                state.batteryStatus = nil
            case .eventClient(.didUpdateStateAttributes(let attributes)):
                return .send(.updateState(attributes))
            case .eventClient(.didConnect):
                return .send(.didConnect)
            case .eventClient(.didDisconnect):
                return .send(.didDisconnect)
            default:
                break
            }
            return .none
        }
        .ifLet(\.$alert, action: \.alert)
    }

    static let previewStore = Store(initialState: previewState) {
        Api()
    }
}
