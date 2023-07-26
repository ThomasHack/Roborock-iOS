//
//  StatusView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import ComposableArchitecture
import SwiftUI

struct StatusView: View {
    let store: Store<Main.State, Main.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack(spacing: 10) {
                StatusItemView(label: "home.battery",
                               unit: "%",
                               iconName: viewStore.batteryIcon,
                               value: viewStore.apiState.battery
                )

                StatusItemView(label: "home.cleanTime",
                               unit: "min",
                               iconName: "stopwatch",
                               value: viewStore.apiState.cleanTime
                )

                StatusItemView(label: "home.cleanArea",
                               unit: "qm",
                               iconName: "square.dashed",
                               value: viewStore.apiState.cleanArea
                )
            }
        }
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView(store: Main.previewStore)
    }
}
