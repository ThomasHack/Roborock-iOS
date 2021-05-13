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
            if let status = viewStore.api.status {
                HStack {
                    StatusItemView(iconName: viewStore.batteryIcon, label: "Battery", value: status.battery)

                    StatusItemView(iconName: "stopwatch", label: "Clean Time", value: status.cleanTime)

                    StatusItemView(iconName: "square.dashed", label: "Clean Area", value: status.cleanArea)
                }
                .padding()
            }
        }
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView(store: Main.previewStoreHome)
    }
}
