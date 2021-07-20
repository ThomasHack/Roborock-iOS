//
//  ButtonView.swift
//  WatchApp Extension
//
//  Created by Thomas Hack on 17.07.21.
//

import ComposableArchitecture
import SwiftUI

struct ButtonView: View {
    let store: Store<Home.HomeFeatureState, Home.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Button {
                    viewStore.send(.driveHome)
                } label: {
                    Image(systemName: "house.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(CircularButtonStyle())
                .disabled(!viewStore.api.isConnected || viewStore.api.state == .charging)

                if !viewStore.api.inCleaning && !viewStore.api.inReturning {
                    Button {
                        viewStore.send(.toggleSegmentsModal(true))
                    } label: {
                        Image(systemName: "play.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .offset(x: 2, y: 0)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!viewStore.api.isConnected)

                } else {
                    Button {
                        viewStore.send(.stopCleaning)
                    } label: {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                    .disabled(!viewStore.api.isConnected)
                }

                if viewStore.api.inCleaning && viewStore.api.inReturning {
                    Button {
                        viewStore.send(.pauseCleaning)
                    } label: {
                        Image(systemName: "pause.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                    .disabled(!viewStore.api.isConnected)
                }

                Button {
                    viewStore.send(.toggleFanspeedModal(true))
                } label: {
                    Image(systemName: "speedometer")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(CircularButtonStyle())
                .disabled(!viewStore.api.isConnected)
            }
        }
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(store: Main.previewStoreHome)
    }
}
