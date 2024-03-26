//
//  StatusView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import ComposableArchitecture
import RoborockApi
import SwiftUI

struct MapView: View {
    @Bindable var store: StoreOf<Api>

    @State var zoom = 1.0

    var body: some View {
        if store.mapImage != nil, !store.entityImages.images.isEmpty {
            GeometryReader { geometry in
                ZStack {
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
                        .modifier(
                            ZoomableModifier(
                                contentSize: CGSize(width: geometry.size.width, height: geometry.size.height - 100),
                                min: 0.8,
                                max: 1.2
                            )
                        )
                        .offset(y: 40)
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height - 100,
                            alignment: .top
                        )
                    }
                }
            }
        } else {
            Spacer()
            if store.connectivityState == .connected {
                ProgressView()
                    .foregroundColor(Color(UIColor.label))
            }
            Spacer()
        }
    }
}

#Preview {
    MapView(store: Api.previewStore)
}
