//
//  SettingsView.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 30.11.23.
//

import ComposableArchitecture
import SwiftUI

struct SettingsView: View {
    @Bindable var store: StoreOf<Settings>

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            Text("settings.host")
            HStack(spacing: 12) {
                Text("https://")
                    .foregroundColor(Color(.quaternaryLabel))
                TextField("roborock", text: $store.hostInput)
                    .keyboardType(.URL)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
            }

            Button {
                store.send(.doneButtonTapped)
            } label: {
                Text("Save")
            }
            Spacer()
        }
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true), content: {
            SettingsView(store: Settings.previewStore)
        })
}
