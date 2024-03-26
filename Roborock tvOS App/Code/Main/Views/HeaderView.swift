//
//  HeaderView.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 30.11.23.
//

import ComposableArchitecture
import SwiftUI

struct HeaderView: View {
    let store: StoreOf<Main>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            if let state = viewStore.apiState.status?.state {
                VStack {
                    VStack {
                        Image(systemName: viewStore.apiState.state.iconName)
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
        })
    }
}

#Preview {
    HeaderView(store: Main.previewStore)
}
