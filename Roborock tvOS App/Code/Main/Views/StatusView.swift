//
//  StatusView.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 30.11.23.
//

import ComposableArchitecture
import SwiftUI

struct StatusView: View {
    let store: StoreOf<Api>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack(alignment: .center, spacing: 10) {
                StatusItemView(label: "home.battery",
                               unit: "%",
                               iconName: viewStore.batteryIcon,
                               value: viewStore.batteryValue
                )
                StatusItemView(label: "home.cleanTime",
                               unit: "min",
                               iconName: "stopwatch",
                               value: viewStore.cleanTime
                )
                StatusItemView(label: "home.cleanArea",
                               unit: "qm",
                               iconName: "square.dashed",
                               value: viewStore.cleanArea
                )
            }
        })
    }
}

#Preview {
    StatusView(store: Api.previewStore)
}
