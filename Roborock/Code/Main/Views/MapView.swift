//
//  StatusView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import ComposableArchitecture
import SwiftUI

struct MapView: View {
    let store: StoreOf<Api>
    let gradient = Gradient(colors: [Color("blue-light"), Color("blue-dark")])

    @State var zoom = 1.0

    var body: some View {
        WithViewStore(store) { viewStore in
            if let mapImage = viewStore.mapImage,
               let forbiddenZonesImage = viewStore.forbiddenZonesImage,
               let chargerImage = viewStore.chargerImage,
               let pathImage = viewStore.pathImage,
               let robotImage = viewStore.robotImage {
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

                                if let segmentLabelsImage = viewStore.segmentLabelsImage {
                                    Image(uiImage: segmentLabelsImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                }

                                Image(uiImage: robotImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            }
                            .frame(width: (geometry.size.width + 250) * zoom)
                        }
                    }
                    .onTapGesture(count: 2, perform: {
                        withAnimation(.spring(), {
                            zoom = zoom > 1.0 ? 1.0 : 2.0
                        })
                    })
                    .frame(width: geometry.size.width, height: geometry.size.height)
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

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(store: Api.previewStore)
    }
}