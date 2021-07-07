//
//  StatusView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import SwiftUI
import ComposableArchitecture

struct StatusView: View {
    let store: Store<Home.HomeFeatureState, Home.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack(spacing: 0) {
                StatusItemView(iconName: viewStore.batteryIcon,
                               label: "home.battery",
                               unit: "%",
                               value: viewStore.binding(get: { $0.api.battery }, send: Home.Action.none))

                StatusItemView(iconName: "stopwatch",
                               label: "home.cleanTime",
                               unit: "min",
                               value: viewStore.binding(get: { $0.api.cleanTime }, send: Home.Action.none))

                StatusItemView(iconName: "square.dashed",
                               label: "home.cleanArea",
                               unit: "qm",
                               value: viewStore.binding(get: { $0.api.cleanArea }, send: Home.Action.none))
            }
        }
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView(store: Main.previewStoreHome)
    }
}
