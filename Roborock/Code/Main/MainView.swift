//
//  MainView.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import RoborockApi
import SwiftUI

struct MainView: View {
    @Bindable var store: StoreOf<Main>

    var body: some View {
        NavigationStack {
            HomeView(store: store)
        }
    }
}

#Preview {
    MainView(store: Main.previewStore)
}
