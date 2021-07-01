//
//  HomeView.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: Store<Home.HomeFeatureState, Home.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            ZStack {
                Image("background")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {

                    HStack {
                        Text("Roborock")
                            .font(.system(size: 42, weight: .bold, design: .default))
                        Spacer()
                    }
                    .padding(.top, 36)
                    .padding(.bottom, 0)
                    .padding(.horizontal, 16)
                    
                    if viewStore.api.connectivityState == .connected, let status = viewStore.api.status {

                        HStack {
                            Text("Status:")
                                .font(.system(size: 16, weight: .light, design: .default))
                            Text("\(status.stateHumanReadable)")
                                .font(.system(.headline))
                            Spacer()

                        }
                        .padding(.horizontal)

                        MapView(store: store)

                        StatusView(store: store)

                        ButtonView(store: store)
                    }
                    Spacer()
                }
            }
            .popover(isPresented: viewStore.binding(get: { $0.presentRoomSelection }, send: Home.Action.toggleRoomSelection)){
                NavigationView {
                    SegmentList(store: store)
                        .navigationBarTitle("Select Room", displayMode: .large)
                        .navigationBarItems(leading: HStack {
                            Button(action: { viewStore.send(.toggleRoomSelection(false))}) {
                                Text("Cancel")
                            }
                        }, trailing: HStack {
                            Button(action: {
                                viewStore.send(.startCleaning)
                                viewStore.send(.toggleRoomSelection(false))
                            }) {
                                Text("Start")
                            }
                        })
                }
            }
        }
        .onAppear {
            let viewStore = ViewStore(store)
            viewStore.send(.fetchSegments)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: Main.previewStoreHome)
    }
}
