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
                                   label: "Clean Time",
                                   unit: "h",
                                   value: store.apiState.cleanTimeReadable
                    )

                    StatusTileView(iconName: "square.dashed",
                                   label: "Clean Area",
                                   unit: "qm",
                                   value: store.apiState.cleanAreaReadable
                    )
                }
                .padding(.leading, 8)
            }

            ButtonView(store: store)
        }
        .sheet(isPresented: $store.showSegmentsModal, content: {
            SegmentList(store: store)
        })
        .sheet(isPresented: $store.showFanspeedModal, content: {
            FanspeedList(store: store)
        })
        .sheet(isPresented: $store.showWaterUsageModal, content: {
            WaterUsageList(store: store)
        })
    }
}

#Preview {
    NavigationStack {
        HomeView(store: Main.previewStore)
    }
}
