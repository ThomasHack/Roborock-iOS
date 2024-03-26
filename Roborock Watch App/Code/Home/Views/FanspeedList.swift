//
//  FanspeedList.swift
//  FanspeedList
//
//  Created by Hack, Thomas on 20.07.21.
//

import ComposableArchitecture
import SwiftUI

struct FanspeedList: View {
    @Bindable var store: StoreOf<Main>

    var body: some View {
        ScrollView {
            VStack {
                ForEach(store.fanSpeedPresets, id: \.self) { value in
                    Button {
                        store.send(.controlFanSpeed(value))
                    } label: {
                        HStack {
                            Text(value.rawValue)
                            Spacer()
                            if store.apiState.fanSpeed.rawValue == value.rawValue {
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

struct FanspeedList_Previews: PreviewProvider {
    static var previews: some View {
        FanspeedList(store: Main.previewStore)
    }
}
