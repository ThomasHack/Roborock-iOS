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
                                    if viewStore.api.rooms.contains(id) {
                                        let index = Int(viewStore.api.rooms.firstIndex(of: id) ?? 0)
                                        ZStack {
                                            Circle()
                                                .foregroundColor(Color("primary"))
                                                .frame(width: 24, height: 24)
                                            Text("\(index + 1)")
                                        }
                                    } else {
                                        Circle()
                                            .strokeBorder(Color("primary"), lineWidth: 2)
                                            .frame(width: 24, height: 24)
                                    }

                                    Text(name)
                                        .padding(.leading, 4)

                                    Spacer()
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
