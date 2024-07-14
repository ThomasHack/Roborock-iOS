//
//  DisconnectedView.swift
//  Roborock
//
//  Created by Hack, Thomas on 02.04.24.
//

import ComposableArchitecture
import SwiftUI

struct DisconnectedView: View {
    @Bindable var store: StoreOf<Main>

    var body: some View {
        if store.host.isEmpty {
            VStack(alignment: .center, spacing: 40) {
                Text("Please enter host or IP address in settings")
                    .foregroundStyle(Color("textColorDark"))

                Button {
                    store.send(.showSettings)
                } label: {
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("settings.open")
                    }
                }
            }
        } else {
            VStack(alignment: .center, spacing: 40) {
                Text("App is not connected to the robot.")
                HStack {
                    Button {
                        store.send(.connect)
                    } label: {
                        HStack {
                            Image(systemName: "bolt.fill")
                            Text("home.connect")
                        }
                    }
                    Button {
                        store.send(.showSettings)
                    } label: {
                        HStack {
                            Image(systemName: "gear")
                            Text("home.settings")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    DisconnectedView(store: Main.previewStore)
}
