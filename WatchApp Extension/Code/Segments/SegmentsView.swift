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

    var body: some View {
        WithViewStore(self.store) { viewStore in
            ScrollView {
                ButtonView(store: store)
            }
            .navigationTitle("Clean Room")
            .sheet(isPresented: viewStore.binding(get: \.showSegmentsModal, send: Home.Action.toggleSegmentsModal)) {
                SegmentList(store: store)
            }
        }
    }
}

struct SegmentsView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentsView(store: Main.previewStoreHome)
    }
}
