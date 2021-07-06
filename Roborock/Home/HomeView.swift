//
//  HomeView.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: Store<Home.HomeFeatureState, Home.Action>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(spacing: 0) {
                
                if viewStore.shared.host != nil {
                    VStack(spacing: 0) {
                        MapView(store: store)
                            .background(Color.blue)
                        
                        VStack(spacing: 0) {
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Roborock")
                                        .font(.system(size: 42, weight: .bold, design: .default))
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        viewStore.send(.settingsButtonTapped)
                                    }) {
                                        Image(systemName: "gear")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                    }
                                    .buttonStyle(SecondaryButtonStyle())
                                }
                                
                                HStack {
                                    Text("Status:")
                                        .font(.system(size: 16, weight: .light, design: .default))
                                    Text(viewStore.api.status?.stateHumanReadable ?? (viewStore.api.connectivityState == .connected ? "Connected" : "Disconnected"))
                                        .font(.system(.headline))
                                    Spacer()
                                    
                                }
                            }
                            .padding(.bottom, 32)
                            
                            StatusView(store: store)
                                .padding(.bottom, 32)
                            
                            ButtonView(store: store)
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(15)
                    }
                    .background(Color("blue"))
                } else {
                    VStack(alignment: .center, spacing: 8) {
                        HStack() {
                            Image(systemName: "bolt.slash.fill")
                            Text("Not Connected")
                        }.foregroundColor(.secondary)
                        Button(action: {
                            if viewStore.shared.host != nil {
                                viewStore.send(.settingsButtonTapped)
                            } else {
                                viewStore.send(.settingsButtonTapped)
                            }
                        }) {
                            Text(viewStore.shared.host != nil ? "Connect" : "Set Host")
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.vertical)
            .sheet(isPresented: viewStore.binding(
                get: \.showSettingsModal,
                send: Home.Action.toggleSettingsModal)
            ) {
                SettingsView(store: Main.store.settings)
            }
            .sheet(isPresented: viewStore.binding(get: { $0.presentRoomSelection }, send: Home.Action.toggleRoomSelection)){
                NavigationView {
                    SegmentList(store: store)
                        .navigationBarTitle("Select Room", displayMode: .large)
                        .navigationBarItems(leading: HStack {
                            Button(action: { viewStore.send(.toggleRoomSelection(false))}) {
                                Text("Cancel")
                            }
                        }, trailing: HStack {
                            Button(action: {
                                viewStore.send(.startCleaning)
                                viewStore.send(.toggleRoomSelection(false))
                            }) {
                                Text("Start")
                            }
                        })
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: Main.previewStoreHome)
            .preferredColorScheme(.dark)
    }
}
