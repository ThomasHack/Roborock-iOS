//
//  SegmentList.swift
//  WatchApp Extension
//
//  Created by Thomas Hack on 17.07.21.
//

import Foundation

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
                                viewStore.send(.toggleRoom(id))
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
