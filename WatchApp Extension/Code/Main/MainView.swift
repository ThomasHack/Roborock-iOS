//
//  MainView.swift
//  WatchApp Extension
//
//  Created by Thomas Hack on 17.07.21.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {

    var store: Store<Main.State, Main.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            if !(viewStore.shared.host ?? "").isEmpty {
                HomeView(store: Main.store.home)
            } else {
                VStack(spacing: 0) {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Main.store)
    }
}
