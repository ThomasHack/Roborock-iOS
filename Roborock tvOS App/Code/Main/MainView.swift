//
//  MainView.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 30.11.23.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {
    let store: StoreOf<Main>

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            if viewStore.host == nil {
                VStack(spacing: 60) {
                    HStack(spacing: 16) {
                        Image(systemName: "info.circle")
                        Text("Please update settings.")
                    }

                    Button {
                        viewStore.send(.showSettings)
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                    }
                }
            } else {
                if viewStore.connectivityState == .disconnected {
                    ZStack(alignment: .center) {
                        VStack {
                            HStack(spacing: 16) {
                                Image(systemName: "info.circle")
                                Text("api.disconnected")
                                Text("\(viewStore.host ?? "-")")
                            }
                            Button {
                                viewStore.send(.connectButtonTapped)
                            } label: {
                                Text("Verbinden")
                            }
                        }
                    }
                } else if viewStore.connectivityState == .connecting {
                    Text("Connecting...")
                } else {
                    ZStack {
                        if viewStore.isMapLoading {
                            Spacer()
                            ProgressView()
                            Spacer()
                        } else {
                            MapView(store: store.scope(
                                state: \.apiState,
                                action: Main.Action.apiAction)
                            )
                            .edgesIgnoringSafeArea(.all)
                        }

                        HStack {
                            VStack(alignment: .center, spacing: 10) {
                                Spacer()
                                HeaderView(store: store)

                                StatusView(store: store.scope(
                                    state: \.apiState,
                                    action: Main.Action.apiAction
                                ))
                                Spacer()
                            }
                            .frame(width: 300)
                            .background(.thinMaterial)
                            Spacer()
                        }
                        .edgesIgnoringSafeArea(.all)

                    }
                    .overlay(alignment: .bottomTrailing, content: {
                        Button {
                            viewStore.send(.toggleRoomSelection(true))
                        } label: {
                            Image(systemName: "play")
                        }
                        .buttonStyle(PrimaryRoundedButtonStyle())
                    })
                    .sheet(isPresented: viewStore.$showRoomSelection, content: {
                        RoomSelectionView(store: store)
                    })
                    .onChange(of: colorScheme) {
                        viewStore.send(.apiAction(.refreshMapImage))
                    }
                }
            }
        })
    }
}

#Preview {
    TabView(selection: .constant(1)) {
        ZStack {
            GradientBackgroundView()
                .edgesIgnoringSafeArea(.all)

            MainView(store: Main.previewStore)
        }
        .tabItem {
            Image(systemName: "house")
            Text("Home")
        }
        .tag(1)
        .toolbarBackground(Color("blue-light"), for: .tabBar)

        Text("")
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(1)
    }
}
