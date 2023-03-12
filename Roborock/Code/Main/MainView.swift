//
//  MainView.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {
    var store: Store<Main.State, Main.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack(alignment: .bottom) {
                Color("blue-dark")
                    .edgesIgnoringSafeArea(.all)
                if (viewStore.sharedState.host ?? "").isEmpty {
                    NotConnectedView(store: store)
                } else {
                    MapView(store: store)

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
            }
            .edgesIgnoringSafeArea(.vertical)
            .sheet(isPresented: viewStore.binding(
                get: \.showRoomSelection,
                send: Main.Action.toggleRoomSelection
            )) {
                RoomSelectionView(store: store)
            }
            .sheet(isPresented: viewStore.binding(
                get: \.showSettings,
                send: Main.Action.toggleSettings
            )) {
                SettingsView(store: Main.store.settings)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Main.store)
    }
}
