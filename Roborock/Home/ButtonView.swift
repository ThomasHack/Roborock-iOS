//
//  StatusView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import SwiftUI
import ComposableArchitecture

struct ButtonView: View {
    let store: Store<Home.HomeFeatureState, Home.Action>

    @State private var showingPopover = false

    var body: some View {
        WithViewStore(self.store) { viewStore in
            
            HStack(alignment: .center, spacing: 16) {
                Button(action: { viewStore.send(.driveHome) }) {
                    Image(systemName: "house.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                .disabled(viewStore.state.connectivityState != .connected)
                .buttonStyle(SecondaryButtonStyle())
                
                if !viewStore.api.inCleaning && !viewStore.api.inReturning {
                    Button(action: { viewStore.send(.toggleRoomSelection(true)) }) {
                        Image(systemName: "play.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .offset(x: 2, y: 0)
                    }
                    .disabled(!viewStore.api.isConnected)
                    .buttonStyle(PrimaryButtonStyle())
                } else {
                    Button(action: { viewStore.send(.stopCleaning) }) {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                    .disabled(!viewStore.api.isConnected)
                    .buttonStyle(PrimaryButtonStyle())
                }

                if viewStore.api.inCleaning && viewStore.api.inReturning {
                    Button(action: { viewStore.send(.pauseCleaning) }) {
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
                        Button(action: { viewStore.send(.api(.setFanspeed(value.rawValue))) }) {
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
        }
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(store: Main.previewStoreHome)
    }
}
