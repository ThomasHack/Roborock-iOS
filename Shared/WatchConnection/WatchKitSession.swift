//
//  WatchKitSession.swift
//  Roborock
//
//  Created by Hack, Thomas on 23.07.21.
//

import ComposableArchitecture
import Foundation

@Reducer
struct WatchKitSession {
    @Dependency(\.watchkitSessionClient) var watchkitSessionClient

    struct State: Equatable {
        @Shared(.appStorage("host")) var host = ""
    }

    @CasePathable
    enum Action {
        case connect
        case requestDataSync
        case updateHost(String)
        case resetHost
        case sendMessageData(WCSessionData)

        case watchkitSessionClient(WatchKitSessionClient.Action)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .connect:
                return .run { send in
                    let actions = try await watchkitSessionClient.connect(WatchKitSessionClient.ID())

                    await withThrowingTaskGroup(of: Void.self) { group in
                        for await action in actions {
                            group.addTask {
                                await send(.watchkitSessionClient(action))
                            }
                        }
                    }
                } catch: { error, _ in
                    print(error.localizedDescription)
                }

            case .requestDataSync:
                return .run { send in
                    let requestData = WCSessionRequestData(action: .synchronizeUserDefaults)
                    await send(.sendMessageData(WCSessionData.requestData(requestData)))
                }

            case let .updateHost(host):
                state.host = host

            case .resetHost:
                state.host = ""

            case let .sendMessageData(message):
                return .run { _ in
                    let data = try JSONEncoder().encode(message)
                    try await watchkitSessionClient.sendMessageData(WatchKitSessionClient.ID(), data)
                } catch: { error, _ in
                    print(error.localizedDescription)
                }

            case .watchkitSessionClient(.sessionDidActivate):
                #if os(iOS)
                return .none
                #else
                print("session did activate")
                return .send(.requestDataSync)
                #endif

            case let .watchkitSessionClient(.didReceiveMessageData(message)):
                switch message {
                case .requestData(let request):
                    switch request.action {
                    case .synchronizeUserDefaults:
                        print("sync")
                        let responseData = WCSessionAppResponseData(host: state.host)
                        return .run { send in
                            await send(.sendMessageData(WCSessionData.responseAppData(responseData)))
                        }

                    }
                case .responseAppData(let response):
                    state.host = response.host

                case .responseWatchData:
                    break
                }

            case .watchkitSessionClient:
                break
            }
            return .none
        }
    }

    static let initialState = State()

    static let previewState = State()
}
