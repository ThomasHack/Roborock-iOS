//
//  RoomSelectionView.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import SwiftUI

struct RoomSelectionView: View {
    let store: Store<Main.State, Main.Action>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            NavigationStack {
                SegmentList(store: store)
                    .navigationTitle("home.selectRoom")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                viewStore.send(.toggleRoomSelection(false))
                            } label: {
                                Text("cancel")
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                viewStore.send(.startCleaning)
                                viewStore.send(.toggleRoomSelection(false))
                            } label: {
                                Text("start")
                                    .bold()
                            }
                        }
                    }
            }
        })
    }
}

struct RoomSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        RoomSelectionView(store: Main.previewStore)
    }
}
