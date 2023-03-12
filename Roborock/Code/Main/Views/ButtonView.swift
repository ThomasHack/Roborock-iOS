//
//  StatusView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import ComposableArchitecture
import RoborockApi
import SwiftUI

struct ButtonView: View {
    let store: Store<Main.State, Main.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                if viewStore.apiState.connectivityState == .connected {

                    HStack(alignment: .center, spacing: 16) {
                        Button {
                            viewStore.send(.driveHome)
                        } label: {
                            Image(systemName: "house.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        }
                        .disabled(!viewStore.apiState.isConnected || viewStore.apiState.state == .charging)
                        .buttonStyle(SecondaryButtonStyle())

                        if !viewStore.apiState.inCleaning && !viewStore.apiState.inReturning {
                            Button {
                                viewStore.send(.toggleRoomSelection(true))
                            } label: {
                                Image(systemName: "play.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .offset(x: 2, y: 0)
                            }
                            .disabled(!viewStore.apiState.isConnected)
                            .buttonStyle(PrimaryButtonStyle())
                        } else {
                            Button {
                                viewStore.send(.stopCleaning)
                            } label: {
                                Image(systemName: "stop.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                            .disabled(!viewStore.apiState.isConnected)
                            .buttonStyle(PrimaryButtonStyle())
                        }

                        if viewStore.apiState.inCleaning && viewStore.apiState.inReturning {
                            Button {
                                viewStore.send(.pauseCleaning)
                            } label: {
                                Image(systemName: "pause.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                            .disabled(!viewStore.apiState.isConnected)
                            .buttonStyle(SecondaryButtonStyle())
                        }

                        FanspeedSelection(store: self.store)
                    }
                } else {
                    VStack {
                        Button {
                            viewStore.send(.connectButtonTapped)
                        } label: {
                            HStack(alignment: .center) {
                                Spacer()
                                if viewStore.apiState.connectivityState == .disconnected {
                                    Text("api.connect")
                                } else {
                                    Text("api.disconnect")
                                        .foregroundColor(.red)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(15)
                        }
                    }
                    .padding(8)
                }
            }
        }
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(store: Main.previewStore)
    }
}
