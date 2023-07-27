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
    let store: StoreOf<Api>
    let gradient = Gradient(colors: [Color("blue-light"), Color("blue-dark")])

    @State var zoom = 1.0

    var body: some View {
        WithViewStore(store) { viewStore in
            if let mapImage = viewStore.mapImage,
               let pathImage = viewStore.pathImage,
               let forbiddenZonesImage = viewStore.forbiddenZonesImage,
               let robotImage = viewStore.robotImage,
               let chargerImage = viewStore.chargerImage,
               let segmentLabelsImage = viewStore.segmentLabelsImage {
                GeometryReader { geometry in
                    ZStack(alignment: .center) {
                        LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)

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
                            .modifier(
                                ZoomableModifier(
                                    contentSize: geometry.size,
                                    min: 0.9,
                                    max: 1.2
                                )
                            )
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height,
                                alignment: .center)
                        }
                    }
                }
            } else {
                Spacer()
                if viewStore.connectivityState == .connected {
                    ProgressView()
                        .foregroundColor(Color(UIColor.label))
                }
                Spacer()
            }
        }
    }
}

#Preview {
    MapView(
        store: Store(
            initialState: Api.State(
                connectivityState: .connected,
                segments: Segments(segment: Api.segments),
                rooms: [],
                status: Api.status,
                mapImage: #imageLiteral(resourceName: "mapImage"),
                pathImage: #imageLiteral(resourceName: "pathImage"),
                forbiddenZonesImage: #imageLiteral(resourceName: "forbiddenZonesImage"),
                robotImage: #imageLiteral(resourceName: "robotImage"),
                chargerImage: #imageLiteral(resourceName: "chargerImage"),
                segmentLabelsImage: #imageLiteral(resourceName: "segmentLabelsImage")
            ),
            reducer: Api()
        )
    )
}
