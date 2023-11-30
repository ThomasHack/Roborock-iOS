//
//  SegmentList.swift
//  WatchApp Extension
//
//  Created by Thomas Hack on 17.07.21.
//

import Foundation

import ComposableArchitecture
import SwiftUI

struct SegmentList: View {
    let store: StoreOf<Main>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            if let segments = viewStore.apiState.segments?.data {
                ScrollView {
                    VStack {
                        ForEach(segments, id: \.self) { segment in
                            Button {
                                viewStore.send(.toggleRoom(segment.id))
                            } label: {
                                HStack {
                                    if viewStore.apiState.rooms.contains(segment.id) {
                                        let index = Int(viewStore.apiState.rooms.firstIndex(of: segment.id) ?? 0)
                                        ZStack {
                                            Circle()
                                                .foregroundColor(Color("blue-primary"))
                                                .frame(width: 24, height: 24)
                                            Text("\(index + 1)")
                                        }
                                    } else {
                                        Circle()
                                            .strokeBorder(Color("blue-primary"), lineWidth: 2)
                                            .frame(width: 24, height: 24)
                                    }

                                    Text(segment.name)
                                        .padding(.leading, 4)

                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.bottom, 44)
                }
                .overlay(
                    VStack {
                        Spacer()
                        VStack {
                            Button {
                                viewStore.send(.startCleaning)
                            } label: {
                                Text("Start")
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(viewStore.apiState.rooms.isEmpty)
                        }
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom))
                    }
                    .edgesIgnoringSafeArea(.horizontal)
                    .edgesIgnoringSafeArea(.bottom)
                )
            }
        })
    }
}

struct SegmentList_Previews: PreviewProvider {
    static var previews: some View {
        SegmentList(store: Main.previewStore)
    }
}
