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
    let gradient = Gradient(colors: [Color(red: 0.2, green: 0.6314, blue: 0.9608), Color(red: 0.0157, green: 0.4235, blue: 0.8314)])

    @State var scale: CGFloat = 1.0
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(spacing: 0) {
                if let mapImage = viewStore.api.mapImage,
                   let forbiddenZonesImage = viewStore.api.forbiddenZonesImage,
                   let chargerImage = viewStore.api.chargerImage,
                   let pathImage = viewStore.api.pathImage,
                   let robotImage = viewStore.api.robotImage {
                    GeometryReader { geometry in
                        ZStack {
                            Image(uiImage: mapImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width, height: 425)
                                .gesture(MagnificationGesture()
                                    .onChanged({ (scale) in
                                        self.scale = scale
                                    }))
                                .scaleEffect(self.scale)

                            Image(uiImage: forbiddenZonesImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width, height: 425)

                            Image(uiImage: chargerImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width, height: 425)

                            Image(uiImage: pathImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width, height: 425)

                            Image(uiImage: robotImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width, height: 425)
                        }
                        .frame(width: geometry.size.width, height: 425)
                    }.padding(.top, 32)
                } else {
                    ProgressView()
                        .foregroundColor(Color(UIColor.label))
                }
            }
            .frame(height: 425)
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
