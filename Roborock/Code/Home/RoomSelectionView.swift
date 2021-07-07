//
//  RoomSelectionView.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import SwiftUI
import ComposableArchitecture

struct RoomSelectionView: View {
    let store: Store<Home.HomeFeatureState, Home.Action>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                SegmentList(store: store)
                    .navigationBarTitle("home.selectRoom", displayMode: .large)
                    .navigationBarItems(leading: HStack {
                        Button(action: { viewStore.send(.toggleRoomSelection(false))}) {
                            Text("cancel")
                        }
                    }, trailing: HStack {
                        Button(action: {
                            viewStore.send(.startCleaning)
                            viewStore.send(.toggleRoomSelection(false))
                        }) {
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
