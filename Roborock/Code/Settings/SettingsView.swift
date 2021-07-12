//
//  SettingsView.swift
//  Roborock
//
//  Created by Hack, Thomas on 06.07.21.
//

import ComposableArchitecture
import SwiftUI

struct SettingsView: View {
    let store: Store<Settings.SettingsFeatureState, Settings.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                VStack {
                    List {
                        Section(header: Text("settings.host")) {
                            VStack(alignment: .leading) {
                                SectionHeader(text: "settings.host")
                                TextField("ws://roborock.home",
                                          text: viewStore.binding(
                                            get: { $0.hostInput },
                                            send: Settings.Action.hostInputTextChanged)
                                )
                                    .keyboardType(.URL)
                                    .disableAutocorrection(true)
                                    .autocapitalization(.none)
                            }
                        }

                        Button {
                            viewStore.send(.connectButtonTapped)
                        } label: {
                            HStack(alignment: .center) {
                                Spacer()
                                if viewStore.api.connectivityState == .disconnected {
                                    Text("api.connect")
                                } else {
                                    Text("api.disconnect")
                                        .foregroundColor(.red)
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .navigationBarTitle(Text("settings.title"), displayMode: .large)
                .background(Color(.systemBackground))
                .edgesIgnoringSafeArea(.all)
                .padding([.top], 10)
                .navigationBarItems(trailing:
                                        HStack(spacing: 16) {
                    Button {
                        viewStore.send(.doneButtonTapped)
                    } label: {
                        Text("done")
                            .font(.system(size: 17, weight: .bold))
                    }
                }
                )
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: Main.previewStoreSettings)
    }
}
