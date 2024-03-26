//
//  StatusView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import ComposableArchitecture
import RoborockApi
import SwiftUI

struct FanSpeedSelection: View {
    @Bindable var store: StoreOf<Api>

    private let offIcon = "fan.slash.fill"
    private let onIcon = "fan.fill"

    var body: some View {
        VStack(alignment: .leading) {
            Text("Fanspeed")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color("textColorDark"))
            Picker("Fanspeed", selection: $store.fanSpeed.sending(\.controlFanSpeed)) {
                ForEach(FanSpeedControlPreset.allCases, id: \.self) { value in
                    Text(value.rawValue.capitalized)
                        .tag(value)
                }
            }
            .pickerStyle(.segmented)
            .tint(Color("textColorDark"))
        }
    }
}

#Preview {
    ZStack {
        Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all)
        FanSpeedSelection(store: Api.previewStore)
    }
}
