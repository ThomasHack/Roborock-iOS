//
//  HomeView.swift
//  Roborock
//
//  Created by Hack, Thomas on 11.03.24.
//

import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    @Bindable var store: StoreOf<Main>
    @State private var expanded = false
    @State private var offset: CGFloat = 325
    @GestureState private var startOffset: CGFloat?

    private let minOffset: CGFloat = 60
    private let maxOffset: CGFloat = 325

    var swipe: some Gesture {
        DragGesture()
            .onChanged { value in
                var newOffset = startOffset ?? offset
                newOffset += value.translation.height
                offset = max(newOffset, 0)
            }
            .onEnded { value in
                let drag = max(value.translation.height, value.predictedEndTranslation.height)
                let midOffset = (minOffset + maxOffset) / 2
                let newOffset = drag < midOffset ? minOffset : maxOffset
                withAnimation(Animation.spring()) {
                    expanded = newOffset == minOffset
                    offset = newOffset
                }
            }
            .updating($startOffset) { _, startOffset, _ in
                startOffset = startOffset ?? offset // 2
            }
    }

    let gradient = Gradient(colors: [Color("blue-light"), Color("blue-dark")])

    var body: some View {
        ZStack(alignment: .bottom) {
            if store.host == nil {
                NotConnectedView(store: store)
            } else {
                LinearGradient(gradient: gradient,
                               startPoint: .top,
                               endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                GeometryReader { geometry in
                    ZStack(alignment: .top) {
                        MapView(store: store.scope(
                            state: \.apiState,
                            action: \.apiAction)
                        )
                        VStack {
                            TitleView(store: store.scope(state: \.apiState, action: \.apiAction))
                            HeaderView(store: store.scope(state: \.apiState, action: \.apiAction))
                        }
                        .padding(.bottom)
                        .foregroundStyle(Color("textColorDark"))
                        .padding(.top, UIEdgeInsets.safeAreaInsets.top)
                    }
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height - (expanded ? 350 : 80)
                    )
                }

                VStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 40, height: 4)
                        .foregroundStyle(.thinMaterial)
                    ButtonView(store: store.scope(state: \.apiState, action: \.apiAction))
                    FanSpeedSelection(store: store.scope(state: \.apiState, action: \.apiAction))
                    WaterUsageSelection(store: store.scope(state: \.apiState, action: \.apiAction))
                    VStack(alignment: .leading) {
                        Text("Attachments")
                            .font(.system(size: 16, weight: .semibold))
                        HStack {
                            ForEach(store.apiState.attachments, id: \.self) { attachment in
                                StatusItemView(label: attachment.attached ? "Attached" : "Not attached",
                                               unit: "",
                                               iconName: attachment.icon,
                                               value: attachment.type.rawValue.capitalized
                                )
                            }
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 25)
                .frame(height: 450)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .offset(y: offset)
                .gesture(swipe)
            }
        }
        .edgesIgnoringSafeArea(.vertical)
        .sheet(isPresented: $store.showRoomSelection) {
            RoomSelectionView(store: store)
        }
    }
}

#Preview {
    HomeView(store: Main.previewStore)
}
