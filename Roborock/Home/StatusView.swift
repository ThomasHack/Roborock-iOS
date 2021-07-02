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
            HStack {
                StatusItemView(iconName: viewStore.batteryIcon,
                               label: "Battery",
                               value: "\(viewStore.api.status?.battery ?? 0)",
                               unit: "%")

                StatusItemView(iconName: "stopwatch",
                               label: "Clean Time",
                               value: String(format: "%.2f", viewStore.api.status?.cleanTime ?? 0),
                               unit: "min")

                StatusItemView(iconName: "square.dashed",
                               label: "Clean Area",
                               value: String(format: "%.2f", round(Double(viewStore.api.status?.cleanArea ?? 0)/10000)),
                               unit: "qm")
            }
            .padding()
        }
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView(store: Main.previewStoreHome)
    }
}
