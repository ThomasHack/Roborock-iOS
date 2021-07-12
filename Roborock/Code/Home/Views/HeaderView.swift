//
//  HeaderView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import ComposableArchitecture
import SwiftUI

struct HeaderView: View {
    let store: Store<Home.HomeFeatureState, Home.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(spacing: 0) {
                HStack {
                    Text("Roborock")
                        .font(.system(size: 42, weight: .bold, design: .default))

                    Spacer()

                    Button {
                        viewStore.send(.settingsButtonTapped)
                    } label: {
                        Image(systemName: "gear")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }

                HStack {
                    Text("home.status")
                        .font(.system(size: 16, weight: .light, design: .default))
                    if let state = viewStore.api.status?.state {
                        Text(LocalizedStringKey(String("roborock.state.\(state)")))
                    } else {
                        Text(viewStore.api.connectivityState == .connected ? "api.connected" : "api.disconnected")
                            .font(.system(.headline))
                    }
                    Spacer()

                }
            }
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
       HeaderView(store: Main.previewStoreHome)
    }
}
