//
//  MapView.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 30.11.23.
//

import ComposableArchitecture
import RoborockApi
import SwiftUI

struct MapView: View {
    let store: StoreOf<Api>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            if let mapImage = viewStore.mapImage,
               let pathImage = viewStore.pathImage,
               let forbiddenZonesImage = viewStore.forbiddenZonesImage,
               let robotImage = viewStore.robotImage,
               let chargerImage = viewStore.chargerImage,
               let segmentLabelsImage = viewStore.segmentLabelsImage {
                GeometryReader { geometry in
                    ZStack(alignment: .center) {
                        ScrollView([.vertical, .horizontal], showsIndicators: false) {
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
                            .padding(geometry.size.width * 0.1)
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height,
                                alignment: .center
                            )
                        }
                    }
                }
            }
        })
    }
}

#Preview {
    MapView(store: Api.previewStore)
}
