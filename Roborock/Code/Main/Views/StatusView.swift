//
//  StatusView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import ComposableArchitecture
import SwiftUI

struct StatusView: View {
    let store: StoreOf<Api>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            HStack(spacing: 10) {
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

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all)
            StatusView(store: Api.previewStore)
                .padding()
        }
    }
}
