//
//  DisconnectedView.swift
//  Roborock
//
//  Created by Hack, Thomas on 02.04.24.
//

import ComposableArchitecture
import SwiftUI

struct ConnectedView: View {
    @Bindable var store: StoreOf<Main>

    @State private var expanded = true

    var body: some View {
        ZStack(alignment: .bottom) {
            // Map
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    MapView(store: store.scope(state: \.apiState, action: \.apiAction))

                    VStack {
                        TitleView(store: store.scope(state: \.apiState, action: \.apiAction))
                        HeaderView(store: store.scope(state: \.apiState, action: \.apiAction))
                        Spacer()
                    }
                    .padding(.top, UIEdgeInsets.safeAreaInsets.top)
                    .padding(.bottom)
                    .foregroundStyle(Color("textColorDark"))

                }
                .frame(width: geometry.size.width, height: geometry.size.height - (expanded ? 350 : 80))
            }

            // Overlay sheet
            OverlaySheet(isExpanded: $expanded) {
                ButtonView(store: store)
                if store.connectivityState == .connected {
                    FanSpeedSelection(store: store.scope(state: \.apiState, action: \.apiAction))
                    WaterUsageSelection(store: store.scope(state: \.apiState, action: \.apiAction))
                    AttachmentsView(store: store.scope(state: \.apiState, action: \.apiAction))
                }
            }
        }
        .edgesIgnoringSafeArea(.vertical)
        .sheet(isPresented: $store.showRoomSelection) {
            RoomSelectionView(store: store)
        }
    }
}

#Preview {
    ConnectedView(store: Main.previewStore)
}
