//
//  SegmentsView.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 14.07.21.
//

import ComposableArchitecture
import SwiftUI

struct SegmentsView: View {
    let store: Store<Home.State, Home.Action>

    @State private var currentPage = 0

    var body: some View {
        WithViewStore(self.store) { viewStore in
            if !viewStore.segments.isEmpty {
                List {
                    ForEach(viewStore.segments, id: \.self) { segment in
                        if let name = segment.name, let id = segment.id {
                            Button {
                                // viewStore.send(.api(.toggleRoom(id)))
                            } label: {
                                HStack {
                                    Text(name)
                                    Spacer()
                                    Text("\(id)")
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Clean Room")
    }
}

struct SegmentsView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentsView(store: Home.store)
    }
}
