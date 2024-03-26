//
//  RoomSelectionView.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 30.11.23.
//

import ComposableArchitecture
import SwiftUI

struct RoomSelectionView: View {
    let store: StoreOf<Main>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            NavigationStack {
                VStack {
                    SegmentList(store: store.scope(
                        state: \.apiState,
                        action: Main.Action.apiAction
                    ))

                    Button {
                        viewStore.send(.startCleaning)
                        viewStore.send(.toggleRoomSelection(false))
                    } label: {
                        HStack(spacing: 16) {
                            Text("start")
                            Image(systemName: "play")
                        }
                    }
                }
                .navigationTitle("home.selectRoom")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            viewStore.send(.toggleRoomSelection(false))
                        } label: {
                            Text("cancel")
                        }
                    }
                }
            }
        })
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true), content: {
            RoomSelectionView(store: Main.previewStore)
        })
}
