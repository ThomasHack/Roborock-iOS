//
//  SettingsView.swift
//  Roborock
//
//  Created by Hack, Thomas on 06.07.21.
//

import ComposableArchitecture
import SwiftUI

struct SettingsView: View {
    @Bindable var store: StoreOf<Settings>

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("settings.host")) {
                        HStack(spacing: 0) {
                            Text("https://")
                                .foregroundColor(Color(.quaternaryLabel))
                            TextField("roborock", text: $store.hostInput)
                                .keyboardType(.URL)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("settings.title"), displayMode: .large)
            .background(Color(.systemBackground))
            .edgesIgnoringSafeArea(.all)
            .padding([.top], 10)
            .toolbar {
                Button {
                    store.send(.doneButtonTapped)
                    dismiss()
                } label: {
                    Text("done")
                        .font(.system(size: 17, weight: .bold))
                }
            }
        }
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true), content: {
            SettingsView(store: Settings.previewStore)
        })
}
