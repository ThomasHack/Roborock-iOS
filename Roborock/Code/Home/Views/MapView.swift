//
//  StatusView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import ComposableArchitecture
import SwiftUI

struct MapView: View {
    let store: Store<Home.HomeFeatureState, Home.Action>
    let gradient = Gradient(colors: [Color("blue-light"), Color("blue-dark")])

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(alignment: .center, spacing: 0) {
                if let mapImage = viewStore.api.mapImage,
                   let forbiddenZonesImage = viewStore.api.forbiddenZonesImage,
                   let segmentLabelsImage = viewStore.api.segmentLabelsImage,
                   let chargerImage = viewStore.api.chargerImage,
                   let pathImage = viewStore.api.pathImage,
                   let robotImage = viewStore.api.robotImage {
                    Spacer(minLength: 0)
                    GeometryReader { geometry in
                        ZStack {
                            Image(uiImage: mapImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)

                            Image(uiImage: forbiddenZonesImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)

                            Image(uiImage: chargerImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)

                            Image(uiImage: pathImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)

                            Image(uiImage: segmentLabelsImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)

                            Image(uiImage: robotImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                        .frame(width: geometry.size.width)
                        .frame(minHeight: 500)
                    }
                    Spacer(minLength: 0)
                } else {
                    Spacer()
                    if viewStore.api.connectivityState == .connected {
                        ProgressView()
                            .foregroundColor(Color(UIColor.label))
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom))
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(store: Main.previewStoreHome)
    }
}
