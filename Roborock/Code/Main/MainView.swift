//
//  MainView.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {
    var store: Store<Main.State, Main.Action>

    var body: some View {
        WithViewStore(self.store) { _ in
            HomeView(store: Main.store.home)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Main.store)
    }
}
