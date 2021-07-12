//
//  SegmentList.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import SwiftUI

struct SegmentList: View {
    let store: Store<Home.HomeFeatureState, Home.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            if let segments = viewStore.api.segments?.data {
                List {
                    ForEach(segments, id: \.self) { segment in
                        if let name = segment.name, let id = segment.id {
                            Button {
                                viewStore.send(.api(.toggleRoom(id)))
                            } label: {
                                HStack {
                                    Text(name)
                                    Spacer()
                                    if viewStore.api.rooms.contains(id) {
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
