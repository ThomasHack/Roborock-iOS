//
//  HeaderView.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 30.11.23.
//

import ComposableArchitecture
import SwiftUI

struct HeaderView: View {
    @Bindable var store: StoreOf<Main>

    var body: some View {
        if let state = store.apiState.status?. {
            VStack {
                VStack {
                    Image(systemName: store.apiState.status.iconName)
                        .foregroundColor(Color("textColorDark"))
                }
                .frame(height: 28)

                Text(LocalizedStringKey(String("roborock.state.\(state)")))
                    .font(.headline)
                    .foregroundColor(Color("textColorDark"))

                Text("Status")
                    .font(.caption2)
                    .foregroundColor(Color("textColorLight"))
            }
            .padding()
        }
    }
}

#Preview {
    HeaderView(store: Main.previewStore)
}
