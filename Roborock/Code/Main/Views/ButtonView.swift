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
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack {
                if viewStore.connectivityState == .connected {
                    HStack(alignment: .center, spacing: 16) {
                        Button {
                            viewStore.send(.driveHome)
                        } label: {
                            Image(systemName: "house.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        }
                        .disabled(viewStore.apiState.state == .charging)
                        .buttonStyle(SecondaryRoundedButtonStyle())

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
                            .buttonStyle(PrimaryRoundedButtonStyle())
                        } else {
                            Button {
                                viewStore.send(.stopCleaning)
                            } label: {
                                Image(systemName: "stop.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                            .buttonStyle(PrimaryRoundedButtonStyle())
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
                            .buttonStyle(SecondaryRoundedButtonStyle())
                        }

                        FanspeedSelection(store: self.store)
                    }
                } else if viewStore.connectivityState == .connecting {
                    VStack {
                        ProgressView()
                    }
                } else {
                    VStack {
                        Button {
                            viewStore.send(.connectButtonTapped)
                        } label: {
                            HStack(alignment: .center) {
                                Spacer()
                                Text("api.connect")
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
            .frame(height: 70)
        })
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all)
            ButtonView(store: Main.previewStore)
        }
    }
}
