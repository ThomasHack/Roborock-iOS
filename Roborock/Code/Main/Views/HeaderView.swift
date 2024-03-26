//
//  HeaderView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import ComposableArchitecture
import SwiftUI

struct HeaderView: View {
    @Bindable var store: StoreOf<Api>

    var body: some View {
        HStack {
            StatusLabel(label: "home.battery", unit: "%", value: store.batteryValue)
            Divider()
            StatusLabel(label: "home.cleanTime", unit: "min", value: store.cleanTimeReadable)
            Divider()
            StatusLabel(label: "home.cleanArea", unit: "qm", value: store.cleanAreaReadable)
        }
        .frame(height: 30)
    }
}

#Preview {
    HeaderView(store: Api.previewStore)
}
