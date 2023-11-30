//
//  SettingsView.swift
//  Roborock
//
//  Created by Hack, Thomas on 06.07.21.
//

import ComposableArchitecture
import SwiftUI

struct SettingsView: View {
    let store: StoreOf<Settings>

    @Environment(\.dismiss) var dismiss

    var body: some View {
        WithViewStore(self.store, observe: { $0 }, content: { viewStore in
            NavigationView {
                VStack {
                    Form {
                        Section(header: Text("settings.host")) {
                            HStack(spacing: 0) {
                                Text("wss://")
                                    .foregroundColor(Color(.quaternaryLabel))
                                TextField("roborock", text: viewStore.$hostInput)
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
                        viewStore.send(.doneButtonTapped)
                        dismiss()
                    } label: {
                        Text("done")
                            .font(.system(size: 17, weight: .bold))
                    }
                }
            }
        })
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .sheet(isPresented: .constant(true), content: {
                SettingsView(store: Settings.previewStore)
            })
    }
}
