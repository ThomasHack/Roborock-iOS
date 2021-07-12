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
    let store: Store<Home.HomeFeatureState, Home.Action>

    @State private var showingPopover = false

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                if viewStore.api.connectivityState == .connected {
                    HStack(alignment: .center, spacing: 16) {
                        Button {
                            viewStore.send(.driveHome)

                        } label: {
                            Image(systemName: "house.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        }
                        .disabled(viewStore.api.connectivityState != .connected || viewStore.api.state == .charging)
                        .buttonStyle(SecondaryButtonStyle())

                        if !viewStore.api.inCleaning && !viewStore.api.inReturning {
                            Button {
                                viewStore.send(.toggleRoomSelection(true))
                            } label: {
                                Image(systemName: "play.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .offset(x: 2, y: 0)
                            }
                            .disabled(!viewStore.api.isConnected)
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
                            .disabled(!viewStore.api.isConnected)
                            .buttonStyle(PrimaryButtonStyle())
                        }

                        if viewStore.api.inCleaning && viewStore.api.inReturning {
                            Button {
                                viewStore.send(.pauseCleaning)
                            } label: {
                                Image(systemName: "pause.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                            .disabled(!viewStore.api.isConnected)
                            .buttonStyle(SecondaryButtonStyle())
                        }

                        Menu(content: {
                            ForEach(Fanspeed.allCases.reversed(), id: \.self) { value in
                                Button {
                                    viewStore.send(.api(.setFanspeed(value.rawValue)))
                                } label: {
                                    HStack {
                                        Text(value.label)
                                        Spacer()
                                        if viewStore.state.api.status?.fanPower == value.rawValue {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }                        }
                        }, label: {
                            Image(systemName: "speedometer")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        })
                        .padding(16)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                    }
                } else {
                    VStack {
                        Button {
                            viewStore.send(.connectButtonTapped)
                        } label: {
                            HStack(alignment: .center) {
                                Spacer()
                                if viewStore.api.connectivityState == .disconnected {
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
        ButtonView(store: Main.previewStoreHome)
    }
}
