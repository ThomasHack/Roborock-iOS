//
//  SegmentsView.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 14.07.21.
//

import ComposableArchitecture
import SwiftUI

struct SegmentsView: View {
    let store: Store<Home.HomeFeatureState, Home.Action>

    @State private var currentPage = 0

    var body: some View {
        WithViewStore(self.store) { _ in
            VStack {
                ButtonView(store: store)
                SegmentList(store: store)
            }
            .navigationTitle("Clean Room")
        }
    }
}

struct SegmentsView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentsView(store: Main.previewStoreHome)
    }
}
