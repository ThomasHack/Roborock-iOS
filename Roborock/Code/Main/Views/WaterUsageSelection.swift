//
//  StatusView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import ComposableArchitecture
import RoborockApi
import SwiftUI

struct WaterUsageSelection: View {
    @Bindable var store: StoreOf<Api>

    private let offIcon = "drop.degreesign.slash.fill"
    private let onIcon = "drop.degreesign.fill"

    var body: some View {
        VStack(alignment: .leading) {
            Text("Water Usage")
                .font(.system(size: 16, weight: .semibold))
            Picker("Water Usage", selection: $store.waterUsage.sending(\.controlWaterUsage)) {
                ForEach(WaterUsageControlPreset.allCases, id: \.self) { value in
                    Text(value.rawValue.capitalized)
                        .tag(value)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

#Preview {
    ZStack {
        Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all)
        WaterUsageSelection(store: Api.previewStore)
    }
}
