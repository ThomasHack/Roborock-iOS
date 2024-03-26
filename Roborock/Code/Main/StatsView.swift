//
//  StatsView.swift
//  Roborock
//
//  Created by Hack, Thomas on 11.03.24.
//

import ComposableArchitecture
import SwiftUI

struct StatsView: View {
    @Bindable var store: StoreOf<Main>

    var body: some View {
        List {
            Section("Current") {
                Text("Time \(store.apiState.cleanTimeReadable)min")
                Text("Area \(store.apiState.cleanAreaReadable)qm")
            }
            Section("Total") {
                Text("Time \(store.apiState.totalCleanTimeReadable)h")
                Text("Area \(store.apiState.totalCleanAreaReadable)qm")
            }
        }
    }
}

#Preview {
    StatsView(store: Main.previewStore)
}
