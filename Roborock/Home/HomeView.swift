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
            ZStack {
                Image("background")
                    .resizable()
                    // .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)

                VStack {

                    HStack {
                        Text("Roborock")
                            .font(.system(size: 36, weight: .bold, design: .default))
                        Spacer()
                    }
                    .padding()

                    if let status = viewStore.api.status {

                        HStack {
                            Text("Status: \(status.humanState)")
                            Spacer()
                            Button(action: { viewStore.send(.fetchStatus)}) {
                                Image(systemName: "arrow.clockwise")
                            }
                            .padding()
                        }
                        .padding()

                        SegmentList(store: store)

                        Spacer()

                        HStack(spacing: 0) {
                            Button(action: { viewStore.send(.driveHome) }) {
                                Image(systemName: "house.fill")
                            }
                            .padding()

                            if status.inCleaning == 0 && status.inReturning == 0 {
                                Button(action: { viewStore.send(.startCleaning) }) {
                                    Image(systemName: "play.fill")
                                }
                                .padding()
                            } else {

                                Button(action: { viewStore.send(.stopCleaning) }) {
                                    Image(systemName: "stop.fill")
                                }
                                .padding()
                            }

                            /* Button(action: { viewStore.send(.pauseCleaning) }) {
                                Image(systemName: "pause.fill")
                            }
                            .disabled(status.inCleaning == 0 && status.inReturning == 0)
                            .padding()

                            Button(action: { viewStore.send(.fetchMap)}) {
                                Image(systemName: "map.fill")
                            }
                            .padding()

                            Button(action: {
                                viewStore.send(.selectAll)
                            }) {
                                Image(systemName: "list.bullet")
                            }
                            .padding()*/
                        }
                        Spacer()
                    }

                    Spacer()

                    if let status = viewStore.api.status {
                        HStack {
                            StatusItemView(iconName: viewStore.batteryIcon, label: "Battery", value: status.battery)

                            StatusItemView(iconName: "stopwatch", label: "Clean Time", value: status.cleanTime)

                            StatusItemView(iconName: "square.dashed", label: "Clean Area", value: status.cleanArea)
                        }
                        .padding()
                    }
                }
            }
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
