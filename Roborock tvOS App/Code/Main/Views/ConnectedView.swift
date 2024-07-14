//
//  DisconnectedView.swift
//  Roborock
//
//  Created by Hack, Thomas on 02.04.24.
//

import ComposableArchitecture
import SwiftUI

struct ConnectedView: View {
    @Bindable var store: StoreOf<Main>

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            MapView(store: store.scope(state: \.apiState, action: \.apiAction))

            HStack {
                VStack(alignment: .center, spacing: 10) {
                    Spacer()
                    TitleView(store: store.scope(state: \.apiState, action: \.apiAction))
                    HeaderView(store: store.scope(state: \.apiState, action: \.apiAction))
                    StatusView(store: store.scope(state: \.apiState, action: \.apiAction))
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
                store.send(.toggleRoomSelection(true))
            } label: {
                Image(systemName: "play")
            }
            .buttonStyle(PrimaryRoundedButtonStyle())
        })
        .sheet(isPresented: $store.showRoomSelection, content: {
            RoomSelectionView(store: store)
        })
        .onChange(of: colorScheme) {
            store.send(.apiAction(.redrawMapImage))
        }
    }
}

#Preview {
    ConnectedView(store: Main.previewStore)
}
