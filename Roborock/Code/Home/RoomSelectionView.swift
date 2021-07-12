//
//  RoomSelectionView.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import SwiftUI

struct RoomSelectionView: View {
    let store: Store<Home.HomeFeatureState, Home.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                SegmentList(store: store)
                    .navigationBarTitle("home.selectRoom", displayMode: .large)
                    .navigationBarItems(leading: HStack {
                        Button {
                            viewStore.send(.toggleRoomSelection(false))
                        } label: {
                            Text("cancel")
                        }
                    }, trailing: HStack {
                        Button {
                            viewStore.send(.startCleaning)
                            viewStore.send(.toggleRoomSelection(false))
                        } label: {
                            Text("start")
                        }
                    })
            }
        }
    }
}

struct RoomSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        RoomSelectionView(store: Main.previewStoreHome)
    }
}
