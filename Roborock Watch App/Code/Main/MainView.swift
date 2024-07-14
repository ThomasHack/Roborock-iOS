//
//  MainView.swift
//  WatchApp Extension
//
//  Created by Thomas Hack on 17.07.21.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {
    @Bindable var store: StoreOf<Main>

    var body: some View {
        if !store.host.isEmpty {
            HomeView(store: store)
        } else {
            VStack(spacing: 16) {
                Spacer()
                ProgressView()
                HStack {
                    Button {
                        store.send(.watchKitSession(.connect))
                    } label: {
                        Text("Connect")
                    }
                    Button {
                        store.send(.watchKitSession(.requestDataSync))
                    } label: {
                        Text("Sync")
                    }
                }
                Spacer()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Main.store)
    }
}
