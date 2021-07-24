//
//  ContentView.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 13.07.21.
//

import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    let store: Store<Home.HomeFeatureState, Home.Action>
    let columns = Array(repeating: GridItem(.flexible()), count: 2)

    @State private var currentPage = 0

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(alignment: .leading, spacing: 16) {
                StateTileView(state: viewStore.binding(get: \.api.state, send: Home.Action.none))

                HStack(spacing: 4) {
                    BatteryTileView(value: viewStore.binding(get: \.api.status?.battery, send: Home.Action.none))
                        .frame(width: 68, height: 68)

                    VStack(alignment: .leading, spacing: 8) {
                        StatusTileView(iconName: "stopwatch",
                                       label: "Clean time",
                                       unit: "h",
                                       color: Color("primary"),
                                       value: viewStore.binding(get: { $0.api.cleanTime }, send: Home.Action.none))

                        StatusTileView(iconName: "square.dashed",
                                       label: "Clean area",
                                       unit: "qm",
                                       color: Color("primary"),
                                       value: viewStore.binding(get: { $0.api.cleanArea }, send: Home.Action.none))
                    }
                    .padding(.leading, 8)
                }

                ButtonView(store: self.store)
            }
            .navigationTitle("Roborock")
            .padding(.top, 16)
            .sheet(isPresented: viewStore.binding(get: \.showSegmentsModal, send: Home.Action.toggleSegmentsModal)) {
                SegmentList(store: store)
            }
            .sheet(isPresented: viewStore.binding(get: \.showFanspeedModal, send: Home.Action.toggleFanspeedModal)) {
                FanspeedList(store: store)
            }
        }
        .navigationTitle("Status")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: Home.previewStore)
    }
}
