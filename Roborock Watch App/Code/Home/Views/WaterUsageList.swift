//
//  FanspeedList.swift
//  FanspeedList
//
//  Created by Hack, Thomas on 20.07.21.
//

import ComposableArchitecture
import SwiftUI

struct WaterUsageList: View {
    @Bindable var store: StoreOf<Main>

    var body: some View {
        ScrollView {
            VStack {
                ForEach(store.waterUsagePresets, id: \.self) { value in
                    Button {
                        store.send(.controlWaterUsage(value))
                    } label: {
                        HStack {
                            Text(value.rawValue)
                            Spacer()
                            if store.apiState.waterUsage.rawValue == value.rawValue {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct WaterUsageList_Previews: PreviewProvider {
    static var previews: some View {
        WaterUsageList(store: Main.previewStore)
    }
}
