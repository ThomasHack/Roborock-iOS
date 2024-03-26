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
    @Bindable var store: StoreOf<Api>

    var body: some View {
        VStack {
            if store.connectivityState == .connected {
                HStack(alignment: .center, spacing: 16) {
                    Button {
                        store.send(.driveHome)
                    } label: {
                        Image(systemName: "house.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                    .disabled(store.robotStatus?.value == .docked)
                    .buttonStyle(SecondaryRoundedButtonStyle())

                    if !store.inCleaning && !store.inReturning {
                        Button {
                            // store.send(.toggleRoomSelection(true))
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
                            store.send(.stopCleaning)
                        } label: {
                            Image(systemName: "stop.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(PrimaryRoundedButtonStyle())
                    }

                    if store.inCleaning && store.inReturning {
                        Button {
                            store.send(.pauseCleaning)
                        } label: {
                            Image(systemName: "pause.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(SecondaryRoundedButtonStyle())
                    }

                    Button {
                        // store.send(.toggleSettings(true))
                    } label: {
                        Image(systemName: "gear")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(SecondaryRoundedButtonStyle())
                }
            } else if store.connectivityState == .connecting {
                VStack {
                    ProgressView()
                }
            } else {
                HStack {
                    Button {
                        // store.send(.connectButtonTapped)
                    } label: {
                        HStack(alignment: .center) {
                            Text("api.connect")
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                    }
                    Button {
                        store.send(.disconnect)
                    } label: {
                        HStack(alignment: .center) {
                            Text("api.disconnect")
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
    }
}

#Preview {
    ZStack {
        Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all)
        ButtonView(store: Api.previewStore)
    }
}
