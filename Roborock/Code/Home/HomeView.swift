//
//  HomeView.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    let store: Store<Home.HomeFeatureState, Home.Action>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(spacing: 0) {
                if (viewStore.shared.host ?? "").isEmpty {
                    NotConnectedView(store: store)
                } else {
                    VStack(spacing: 0) {
                        MapView(store: store)
                            .background(Color.blue)

                        VStack(spacing: 0) {
                            HeaderView(store: store)
                                .padding(.bottom, 32)

                            StatusView(store: store)
                                .padding(.bottom, 32)

                            ButtonView(store: store)
                                .padding(.bottom, 32)
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(15)
                    }
                    .background(Color("blue-dark"))
                }
            }
            .edgesIgnoringSafeArea(.vertical)
            .sheet(isPresented: viewStore.binding(get: \.presentRoomSelection, send: Home.Action.toggleRoomSelection)) {
                RoomSelectionView(store: store)
            }
            .sheet(isPresented: viewStore.binding( get: \.showSettingsModal, send: Home.Action.toggleSettingsModal)) {
                SettingsView(store: Main.store.settings)
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
