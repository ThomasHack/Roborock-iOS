//
//  ButtonView.swift
//  WatchApp Extension
//
//  Created by Thomas Hack on 17.07.21.
//

import ComposableArchitecture
import SwiftUI

struct ButtonView: View {
    let store: StoreOf<Main>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
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
                .disabled(!viewStore.apiState.isConnected || viewStore.apiState.state == .charging)

                if !viewStore.apiState.inCleaning && !viewStore.apiState.inReturning {
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
                    .disabled(!viewStore.apiState.isConnected)

                } else {
                    Button {
                        viewStore.send(.stopCleaning)
                    } label: {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                    .disabled(!viewStore.apiState.isConnected)
                }

                if viewStore.apiState.inCleaning && viewStore.apiState.inReturning {
                    Button {
                        viewStore.send(.pauseCleaning)
                    } label: {
                        Image(systemName: "pause.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                    .disabled(!viewStore.apiState.isConnected)
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
                .disabled(!viewStore.apiState.isConnected)
            }
        })
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(store: Main.previewStore)
    }
}
