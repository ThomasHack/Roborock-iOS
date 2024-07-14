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
        if store.mapImage != nil, !store.entityImages.images.isEmpty {
            GeometryReader { geometry in
                ScrollView([.vertical, .horizontal], showsIndicators: false) {
                    ZStack {
                        if let image = store.mapImage {
                            Image(uiImage: image.associatedValue)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            }
                            ForEach(store.entityImages.zones, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            ForEach(store.entityImages.virtualWalls, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            ForEach(store.entityImages.paths, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            ForEach(store.entityImages.targets, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            if let image = store.entityImages.charger {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            if let image = store.entityImages.robot {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                    .frame(width: geometry.size.width,
                           height: geometry.size.height,
                           alignment: .top
                    )
                }
            }
        } else {
            ZStack {
                ProgressView()
            }
            .frame(maxHeight: .infinity)
        }
    }
}

#Preview {
    MapView(store: Api.previewStore)
}
