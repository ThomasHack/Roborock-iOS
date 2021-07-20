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
            VStack(alignment: .leading, spacing: 8) {
                if let status = viewStore.status {
                    // LazyVGrid(columns: columns) {
                    HStack {
                        BatteryTileView(value: status.battery)
                            .frame(minHeight: 70)

                        VStack(alignment: .leading) {
                            StatusTileView(iconName: "stopwatch",
                                           label: "Clean time",
                                           unit: "h",
                                           color: Color.orange,
                                           value: viewStore.binding(get: { $0.api.cleanTime }, send: Home.Action.none))

                            StatusTileView(iconName: "square.dashed",
                                           label: "Clean area",
                                           unit: "qm",
                                           color: Color.blue,
                                           value: viewStore.binding(get: { $0.api.cleanArea }, send: Home.Action.none))
                        }
                    }

                    if let state = status.vacuumState {
                        // StateTileView(state: state, label: "roborock.state.\(status.state)")
                        Text(LocalizedStringKey(String("roborock.state.\(state.rawValue)")))
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    ButtonView(store: self.store)
                } else {
                    VStack {
                        Spacer()
                        Text("Loading...")
                        Spacer()
                    }
                }
            }
            .sheet(isPresented: viewStore.binding(get: \.showSegmentsModal, send: Home.Action.toggleSegmentsModal)) {
                SegmentList(store: store)
            }
        }
        .navigationTitle("Status")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: Main.previewStoreHome)
    }
}
