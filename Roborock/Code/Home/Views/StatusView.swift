//
//  StatusView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import ComposableArchitecture
import SwiftUI

struct StatusView: View {
    let store: Store<Home.HomeFeatureState, Home.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack(spacing: 0) {
                StatusItemView(label: "home.battery",
                               unit: "%",
                               iconName: viewStore.binding(get: { $0.batteryIcon }, send: Home.Action.none),
                               value: viewStore.binding(get: { $0.api.battery }, send: Home.Action.none))

                StatusItemView(label: "home.cleanTime",
                               unit: "min",
                               iconName: .constant("stopwatch"),
                               value: viewStore.binding(get: { $0.api.cleanTime }, send: Home.Action.none))

                StatusItemView(label: "home.cleanArea",
                               unit: "qm",
                               iconName: .constant("square.dashed"),
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
