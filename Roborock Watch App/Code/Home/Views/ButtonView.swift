//
//  ButtonView.swift
//  WatchApp Extension
//
//  Created by Thomas Hack on 17.07.21.
//

import ComposableArchitecture
import SwiftUI

struct ButtonView: View {
    @Bindable var store: StoreOf<Main>

    var body: some View {
        HStack {
             Button {
                 store.send(.driveHome)
            } label: {
                Image(systemName: "house.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(CircularButtonStyle())
            .disabled(store.apiState.robotStatus?.value == .docked)

            if !store.apiState.inCleaning && !store.apiState.inReturning {
                Button {
                    store.send(.toggleSegmentsModal(true))
                } label: {
                    Image(systemName: "play.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .offset(x: 2, y: 0)
                }
                .buttonStyle(PrimaryButtonStyle())

            } else {
                Button {
                    store.send(.stopCleaning)
                } label: {
                    Image(systemName: "stop.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
            }

            if store.apiState.inCleaning && store.apiState.inReturning {
                Button {
                    store.send(.pauseCleaning)
                } label: {
                    Image(systemName: "pause.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
            }

            Button {
                store.send(.toggleFanspeedModal(true))
            } label: {
                Image(systemName: "speedometer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(CircularButtonStyle())

            Button {
                store.send(.toggleWaterUsageModal(true))
            } label: {
                Image(systemName: "drop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(CircularButtonStyle())
        }
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(store: Main.previewStore)
    }
}
