//
//  ContentView.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 13.07.21.
//

import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    @Bindable var store: StoreOf<Main>

    private let columns = Array(repeating: GridItem(.flexible()), count: 2)

    @State private var currentPage = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let status = store.apiState.robotStatus {
                StateTileView(status: status)
            }

            HStack(spacing: 4) {
                BatteryTileView(value: store.apiState.batteryStatus?.level)
                    .frame(width: 68, height: 68)

                VStack(alignment: .leading, spacing: 8) {
                    StatusTileView(iconName: "stopwatch",
                                   label: "Clean time",
                                   unit: "h",
                                   color: Color("blue-primary"),
                                   value: store.apiState.cleanTimeReadable
                    )

                    StatusTileView(iconName: "square.dashed",
                                   label: "Clean area",
                                   unit: "qm",
                                   color: Color("blue-primary"),
                                   value: store.apiState.cleanAreaReadable
                    )
                }
                .padding(.leading, 8)
            }

            ButtonView(store: store)
        }
        .padding(.top, 16)
        .sheet(isPresented: $store.showSegmentsModal, content: {
            SegmentList(store: store)
        })
        .sheet(isPresented: $store.showFanspeedModal, content: {
            FanspeedList(store: store)
        })
        .sheet(isPresented: $store.showWaterUsageModal, content: {
            WaterUsageList(store: store)
        })
        .navigationTitle("Status")
        .navigationTitle("Roborock")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: Main.previewStore)
    }
}
