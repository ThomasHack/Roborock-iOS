//
//  SegmentList.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import SwiftUI

struct SegmentList: View {
    @Bindable var store: StoreOf<Main>

    var body: some View {
        List {
            ForEach(store.apiState.sortedSegments, id: \.self) { segment in
                Button {
                    store.send(.apiAction(.toggleRoom(segment)))
                } label: {
                    HStack {
                        if store.apiState.selectedSegments.contains(segment) {
                            let index = Int(store.apiState.selectedSegments.firstIndex(of: segment) ?? 0)
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

                        Text(segment.name ?? "-")
                            .padding(.leading, 4)

                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    SegmentList(store: Main.previewStore)
}
