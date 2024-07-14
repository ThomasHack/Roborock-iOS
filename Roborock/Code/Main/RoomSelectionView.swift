//
//  RoomSelectionView.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import SwiftUI

struct RoomSelectionView: View {
    @Bindable var store: StoreOf<Main>

    var body: some View {
        NavigationStack {
            SegmentList(store: store)
                .navigationTitle("home.selectRoom")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            store.send(.toggleRoomSelection(false))
                        } label: {
                            Text("cancel")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            store.send(.apiAction(.startCleaningSegment))
                            store.send(.toggleRoomSelection(false))
                        } label: {
                            Text("start")
                                .bold()
                        }
                        .disabled(store.apiState.selectedSegments.isEmpty)
                    }
                }
        }
    }
}

#Preview {
    RoomSelectionView(store: Main.previewStore)
}
