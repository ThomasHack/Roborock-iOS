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
                if viewStore.status != nil {
                    VStack {
                        if let state = viewStore.api.status?.state {
                            Text(LocalizedStringKey(String("roborock.state.\(state)")))
                                .font(.headline)
                        } else {
                            Text(viewStore.api.connectivityState == .connected ? "api.connected" : "api.disconnected")
                                .font(.headline)
                        }

                        VStack(spacing: 0) {
                            HStack(spacing: 8) {
                                if let status = viewStore.status {
                                    VStack {
                                        ProgressView(viewStore.api.battery, value: Float(status.battery), total: Float(100))
                                            .progressViewStyle(CircularProgressViewStyle(tintColor: Color.green))
                                    }
                                }
                                VStack {
                                    Text("Battery")
                                        .font(.headline)
                                    Spacer(minLength: 0)
                                }
                                Spacer()
                                HStack(alignment: .lastTextBaseline, spacing: 0) {
                                    Text(viewStore.api.battery)
                                        .font(.body)
                                    Text("%")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.gray)
                                }
                            }
                            .padding(.vertical, 8)
                        }

                        StatusItemView(iconName: "stopwatch",
                                       label: "Time",
                                       unit: "h",
                                       color: Color.orange,
                                       value: viewStore.binding(get: { $0.api.cleanTime }, send: Home.Action.none))

                        StatusItemView(iconName: "square.dashed",
                                       label: "Area",
                                       unit: "qm",
                                       color: Color.blue,
                                       value: viewStore.binding(get: { $0.api.cleanArea }, send: Home.Action.none))
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
