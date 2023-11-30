//
//  HeaderView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import ComposableArchitecture
import SwiftUI

struct HeaderView: View {
    let store: Store<Main.State, Main.Action>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    Text("Roborock")
                        .font(.system(size: 42, weight: .bold, design: .default))
                    Spacer()
                    Button {
                        viewStore.send(.toggleSettings(true))
                    } label: {
                        Image(systemName: "gear")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(SecondaryRoundedButtonStyle())
                }
                HStack {
                    Text("home.status")
                        .font(.system(size: 16, weight: .light, design: .default))
                    if let state = viewStore.apiState.status?.state {
                        Text(LocalizedStringKey(String("roborock.state.\(state)")))
                            .font(.system(.headline))
                    } else {
                        Text(viewStore.apiState.connectivityState == .connected ? "api.connected" : "api.disconnected")
                            .font(.system(.headline))
                    }
                    Spacer()
                }
            }
        })
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(store: Main.previewStore)

    }
}
