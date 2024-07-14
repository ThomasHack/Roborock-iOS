//
//  TitleView.swift
//  Roborock
//
//  Created by Hack, Thomas on 26.03.24.
//

import ComposableArchitecture
import SwiftUI

struct TitleView: View {
    @Bindable var store: StoreOf<Api>

    var body: some View {
        if let info = store.robotInfo, let state = store.robotStatus?.value {
             HStack {
                 Text("\(info.manufacturer) \(info.modelName)")
                     .font(.system(size: 16, weight: .bold))
                 Text("-")
                 Text(LocalizedStringKey(String("roborock.state.value.\(state)")))
             }
         } else {
            Text(store.connectivityState == .connected ? "api.connected" : "api.disconnected")
                .font(.system(.headline))
        }
    }
}

#Preview {
    TitleView(store: Api.previewStore)
}
