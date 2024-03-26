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
    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            if viewStore.host == nil {
                VStack(spacing: 20) {
                    Image(systemName: "info.circle")
                        .font(.headline)

                    Text("Please update settings.")
                }
            } else {
                GeometryReader { geometry in
                    ZStack(alignment: .top) {
                        Color("blue-dark")
                            .edgesIgnoringSafeArea(.all)

                        MapView(store: store.scope(
                            state: \.apiState,
                            action: Main.Action.apiAction)
                        )
                        .edgesIgnoringSafeArea(.all)

                        HeaderView(store: store)

                        ZStack(alignment: .bottom) {

                            VStack {
                                Spacer()
                                HStack(alignment: .bottom) {
                                    StatusView(store: store.scope(
                                        state: \.apiState,
                                        action: Main.Action.apiAction
                                    ))
                                    .padding()
                                    .frame(maxWidth: geometry.size.width * 0.33)
                                    Spacer()

                                    Button {
                                        viewStore.send(.toggleRoomSelection(true))
                                    } label: {
                                        Image(systemName: "play")
                                    }
                                    .buttonStyle(PrimaryRoundedButtonStyle())
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: viewStore.binding(
                    get: \.showRoomSelection,
                    send: Main.Action.toggleRoomSelection
                ), content: {
                    RoomSelectionView(store: store)
                })
            }
        })
    }
}

#Preview {
    MainView(store: Main.previewStore)
}
