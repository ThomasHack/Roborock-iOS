//
//  SegmentList.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import SwiftUI

struct SegmentList: View {
    let store: Store<Main.State, Main.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            List {
                ForEach(viewStore.apiState.sortedSegments, id: \.self) { segment in
                    Button {
                        viewStore.send(.apiAction(.toggleRoom(segment.id)))
                    } label: {
                        HStack {
                            if viewStore.apiState.rooms.contains(segment.id) {
                                let index = Int(viewStore.apiState.rooms.firstIndex(of: segment.id) ?? 0)
                                ZStack {
                                    Circle()
                                        .foregroundColor(Color("blue-primary"))
                                        .frame(width: 24, height: 24)
                                    Text("\(index + 1)")
                                        .foregroundColor(Color(.systemBackground))
                                }
                            } else {
                                Circle()
                                    .strokeBorder(Color("blue-primary"), lineWidth: 2)
                                    .frame(width: 24, height: 24)
                            }

                            Text(segment.name)
                                .padding(.leading, 4)

                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

struct SegmentList_Previews: PreviewProvider {
    static var previews: some View {
        SegmentList(store: Main.previewStore)
    }
}
