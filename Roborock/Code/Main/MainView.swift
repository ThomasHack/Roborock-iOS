//
//  MainView.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {
    var store: Store<Main.State, Main.Action>

    @State private var expanded = true
    @State private var offset: CGFloat = 20
    @GestureState private var startOffset: CGFloat?

    var swipe: some Gesture {
        DragGesture()
            .onChanged { value in
                var newOffset = startOffset ?? offset
                newOffset += value.translation.height
                offset = max(newOffset, -20)
            }
            .onEnded { value in
                let max = max(value.translation.height, value.predictedEndTranslation.height)

                withAnimation(Animation.spring()) {
                    offset = max < 200 ? 0 : 250
                    expanded = max < 200 ? true : false
                }
            }
            .updating($startOffset) { _, startOffset, _ in
                startOffset = startOffset ?? offset // 2
            }
    }

    struct ViewState: Equatable {
        var host: String?
        var showRoomSelection: Bool
        var showSettings: Bool

        init(_ state: Main.State) {
            self.host = state.host
            self.showRoomSelection = state.showRoomSelection
            self.showSettings = state.showSettings
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            ZStack(alignment: .bottom) {
                if viewStore.host == nil {
                    NotConnectedView(store: store)
                } else {
                    Color("blue-dark")
                        .edgesIgnoringSafeArea(.all)

                    GeometryReader { geometry in
                        MapView(store: store.scope(
                            state: \.apiState,
                            action: Main.Action.apiAction)
                        )
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height * (expanded ? 0.66 : 1.0)
                        )
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(Color(.secondarySystemBackground))

                        VStack(spacing: 0) {
                            HeaderView(store: store)
                                .padding(.bottom, 32)

                            StatusView(store: store)
                                .padding(.bottom, 32)

                            ButtonView(store: store)
                                .padding(.bottom, 32)
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 25)
                    }
                    .compositingGroup()
                    .frame(height: 350)
                    .offset(y: offset)
                    .gesture(swipe)
                }
            }
            .edgesIgnoringSafeArea(.vertical)
            .sheet(isPresented: viewStore.binding(
                get: \.showRoomSelection,
                send: Main.Action.toggleRoomSelection
            )) {
                RoomSelectionView(store: store)
            }
            .sheet(isPresented: viewStore.binding(
                get: \.showSettings,
                send: Main.Action.toggleSettings
            )) {
                SettingsView(store: Main.store.settings)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Main.previewStore)
    }
}
