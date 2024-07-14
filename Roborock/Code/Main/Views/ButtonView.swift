//
//  StatusView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import ComposableArchitecture
import RoborockApi
import SwiftUI

struct ButtonView: View {
    @Bindable var store: StoreOf<Main>

    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 16) {
                Button {
                    store.send(.apiAction(.driveHome))
                } label: {
                    Image(systemName: "house.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                .disabled(store.apiState.robotStatus?.value == .docked)
                .buttonStyle(SecondaryRoundedButtonStyle())

                if !store.apiState.inCleaning && !store.apiState.inReturning {
                    Button {
                        store.send(.toggleRoomSelection(true))
                    } label: {
                        Image(systemName: "play.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .offset(x: 2, y: 0)
                    }
                    .buttonStyle(PrimaryRoundedButtonStyle())
                } else {
                    Button {
                        store.send(.apiAction(.stopCleaning))
                    } label: {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(PrimaryRoundedButtonStyle())
                }

                if store.apiState.inCleaning && store.apiState.inReturning {
                    Button {
                        store.send(.apiAction(.pauseCleaning))
                    } label: {
                        Image(systemName: "pause.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(SecondaryRoundedButtonStyle())
                }

                Button {
                    store.send(.toggleSettings(true))
                } label: {
                    Image(systemName: "gear")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(SecondaryRoundedButtonStyle())
            }
        }
        .frame(height: 70)
    }
}

#Preview {
    ZStack {
        Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all)
        ButtonView(store: Main.previewStore)
    }
}
