//
//  ContentView.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 13.07.21.
//

import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    let store: StoreOf<Main>

    private let columns = Array(repeating: GridItem(.flexible()), count: 2)

    @State private var currentPage = 0

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack(alignment: .leading, spacing: 16) {
                StateTileView(state: viewStore.apiState.state)

                HStack(spacing: 4) {
                    BatteryTileView(value: viewStore.apiState.status?.battery)
                        .frame(width: 68, height: 68)

                    VStack(alignment: .leading, spacing: 8) {
                        StatusTileView(iconName: "stopwatch",
                                       label: "Clean time",
                                       unit: "h",
                                       color: Color("blue-primary"),
                                       value: viewStore.apiState.cleanTime
                        )

                        StatusTileView(iconName: "square.dashed",
                                       label: "Clean area",
                                       unit: "qm",
                                       color: Color("blue-primary"),
                                       value: viewStore.apiState.cleanArea
                        )
                    }
                    .padding(.leading, 8)
                }

                ButtonView(store: store)
            }
            .navigationTitle("Roborock")
            .padding(.top, 16)
            .sheet(isPresented: viewStore.binding(
                get: \.showSegmentsModal,
                send: Main.Action.toggleSegmentsModal
            )) {
                SegmentList(store: store)
            }
            .sheet(isPresented: viewStore.binding(
                get: \.showFanspeedModal,
                send: Main.Action.toggleFanspeedModal
            )) {
                FanspeedList(store: store)
            }
        })
        .navigationTitle("Status")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: Main.previewStore)
    }
}
