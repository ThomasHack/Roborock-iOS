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
            NavigationView {
                ZStack {
                    Color(UIColor.secondarySystemBackground)
                        .edgesIgnoringSafeArea(.bottom)
                    
                    VStack {
                        if let status = viewStore.api.status {
                            
                            HStack {
                                Text("Status: \(status.humanState)")
                                Spacer()
                                HStack(spacing: 8) {
                                    if status.humanState == "Charging" {
                                        Image(systemName: "battery.100.bolt")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 14)
                                    } else if status.battery < 25 {
                                        Image(systemName: "battery.25")
                                    } else {
                                        Image(systemName: "battery.100")
                                    }
                                    
                                    HStack(alignment: .lastTextBaseline, spacing: 1) {
                                        Text("\(status.battery)")
                                        Text("%")
                                            .font(.system(size: 12))
                                    }
                                }
                            }
                            .padding()
                            
                            SegmentList(store: store)
                            
                            Spacer()
                            
                            HStack {
                                Button(action: { viewStore.send(.driveHome) }) {
                                    Image(systemName: "house.fill")
                                }
                                .padding()
                                
                                Button(action: { viewStore.send(.startCleaning) }) {
                                    Image(systemName: "play.fill")
                                }
                                .disabled(viewStore.state.rooms.isEmpty)
                                .padding()
                                
                                Button(action: { viewStore.send(.pauseCleaning) }) {
                                    Image(systemName: "pause.fill")
                                }
                                .disabled(status.inCleaning == 0 && status.inReturning == 0)
                                .padding()
                                
                                Button(action: { viewStore.send(.stopCleaning) }) {
                                    Image(systemName: "stop.fill")
                                }
                                .disabled(status.inCleaning == 0 && status.inReturning == 0)
                                .padding()
                                
                                Button(action: { viewStore.send(.fetchStatus)}) {
                                    Image(systemName: "arrow.clockwise")
                                }
                                .padding()
                                
                                Button(action: { viewStore.send(.fetchMap)}) {
                                    Image(systemName: "map.fill")
                                }
                                .padding()
                                
                            }
                            Spacer()
                        }
                    }
                }
                // .edgesIgnoringSafeArea(.bottom)
                .navigationBarTitle(Text("Roborock"), displayMode: .automatic)
                .navigationBarItems(trailing:
                                        HStack {
                                            Button(action: {
                                                viewStore.send(.selectAll)
                                            }) {
                                                Image(systemName: "list.bullet")
                                            }
                                        }
                )
            }
            // .navigationViewStyle(StackNavigationViewStyle())
        }.onAppear {
            let viewStore = ViewStore(store)
            viewStore.send(.fetchStatus)
            viewStore.send(.fetchSegments)
            // viewStore.send(.fetchMap)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: Main.previewStoreHome)
    }
}
