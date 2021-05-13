//
//  StatusView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import SwiftUI
import ComposableArchitecture

struct ButtonView: View {
    let store: Store<Home.HomeFeatureState, Home.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            if let status = viewStore.api.status {
                HStack(spacing: 16) {
                    Button(action: { viewStore.send(.driveHome) }) {
                        Image(systemName: "house.fill")
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    if status.inCleaning == 0 && status.inReturning == 0 {
                        Button(action: { viewStore.send(.toggleRoomSelection(true)) }) {
                            Image(systemName: "play.fill")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    } else {
                        Button(action: { viewStore.send(.stopCleaning) }) {
                            Image(systemName: "stop.fill")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }

                    Button(action: { viewStore.send(.pauseCleaning) }) {
                        Image(systemName: "pause.fill")
                    }
                    .disabled(status.inCleaning == 0 && status.inReturning == 0)
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding()
            }
        }
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(store: Main.previewStoreHome)
    }
}
