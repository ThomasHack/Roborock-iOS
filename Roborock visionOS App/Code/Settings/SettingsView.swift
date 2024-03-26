//
//  SettingsView.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 30.11.23.
//

import ComposableArchitecture
import SwiftUI

struct SettingsView: View {
    let store: StoreOf<Settings>

    @Environment(\.dismiss) var dismiss

    var body: some View {
        WithViewStore(self.store, observe: { $0 }, content: { viewStore in
            Form {
                Section(header: Text("settings.host")) {
                    HStack(spacing: 12) {
                        Text("https://")
                            .foregroundColor(Color(.quaternaryLabel))
                        TextField("roborock", text: viewStore.$hostInput)
                            .keyboardType(.URL)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }

                    Button {
                        viewStore.send(.doneButtonTapped)
                    } label: {
                        Text("Save")
                    }
                }
            }
        })
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true), content: {
            SettingsView(store: Settings.previewStore)
        })
}
