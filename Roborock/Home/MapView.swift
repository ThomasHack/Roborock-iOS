//
//  StatusView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import SwiftUI
import ComposableArchitecture

struct MapView: View {
    let store: Store<Home.HomeFeatureState, Home.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(spacing: 0) {
                if let mapImage = viewStore.api.mapImage {
                    Image(uiImage: mapImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .padding()

                } else {
                    ProgressView()
                        .foregroundColor(Color(UIColor.label))
                        .padding(32)
                }
            }
            .frame(height: 320)
            .frame(maxWidth: .infinity)
            .background(LinearGradient(colors: [Color(red: 0.2, green: 0.6314, blue: 0.9608), Color(red: 0.0157, green: 0.4235, blue: 0.8314)],
                                       startPoint: .top,
                                       endPoint: .bottom))
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(store: Main.previewStoreHome)
    }
}
