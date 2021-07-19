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

    @State private var currentPage = 0

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                if let status = viewStore.status {
                    VStack {
                        if let state = status.state {
                            Text(LocalizedStringKey(String("roborock.state.\(state)")))
                                .font(.headline)

                            HStack {
                                BatteryTileView(value: status.battery)

                                StatusItemView(iconName: "stopwatch",
                                               label: "Time",
                                               unit: "h",
                                               color: Color.orange,
                                               value: viewStore.binding(get: { $0.api.cleanTime }, send: Home.Action.none))
                            }

                            HStack {
                                StatusItemView(iconName: "square.dashed",
                                               label: "Area",
                                               unit: "qm",
                                               color: Color.blue,
                                               value: viewStore.binding(get: { $0.api.cleanArea }, send: Home.Action.none))
                            }

                        } else {
                            Text(viewStore.api.connectivityState == .connected ? "api.connected" : "api.disconnected")
                                .font(.headline)
                        }
                    }
                    .padding()
                } else {
                    VStack {
                        Spacer()
                        Text("Loading...")
                        Spacer()
                    }
                }
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
