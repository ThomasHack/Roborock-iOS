//
//  SegmentList.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import SwiftUI
import ComposableArchitecture

struct SegmentList: View {
    let store: Store<Home.HomeFeatureState, Home.Action>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            if let segments = viewStore.api.segments?.data {
                List {
                    ForEach(segments, id: \.self) { segment in
                        if let name = segment.name, let id = segment.id {
                            Button(action: {
                                viewStore.send(.toggleRoom(id))
                            }) {
                                HStack {
                                    Text(name)
                                    Spacer()
                                    if let _ = viewStore.home.rooms.firstIndex(of: id) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SegmentList_Previews: PreviewProvider {
    static var previews: some View {
        SegmentList(store: Main.previewStoreHome)
    }
}
