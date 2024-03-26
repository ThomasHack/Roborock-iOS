//
//  SegmentList.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 30.11.23.
//

import ComposableArchitecture
import RoborockApi
import SwiftUI

struct SegmentList: View {
    let store: StoreOf<Api>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack {
                Form {
                    ForEach(viewStore.sortedSegments, id: \.self) { segment in
                        Button {
                            viewStore.send(.toggleRoom(segment.id))
                        } label: {
                            HStack {
                                if viewStore.rooms.contains(segment.id) {
                                    let index = Int(viewStore.rooms.firstIndex(of: segment.id) ?? 0)
                                    ZStack {
                                        Circle()
                                            .foregroundColor(Color("blue-primary"))
                                            .frame(width: 36, height: 36)
                                        Text("\(index + 1)")
                                            .foregroundColor(Color(.white))
                                    }
                                } else {
                                    Circle()
                                        .strokeBorder(Color("blue-primary"), lineWidth: 2)
                                        .frame(width: 36, height: 36)
                                }

                                Text(segment.name)
                                    .padding(.leading, 4)

                                Spacer()
                            }
                        }
                    }
                }
            }
        })
    }
}

#Preview {
    SegmentList(store: Store(initialState: Api.State(
        connectivityState: .connected,
        segments: Segments(segment: Api.segments)
    ), reducer: {
        Api()
    }))
}
