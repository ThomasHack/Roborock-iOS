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
    let store: Store<Home.HomeFeatureState, Home.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            if let segments = viewStore.api.segments?.data {
                ScrollView {
                    VStack {
                        ForEach(segments, id: \.self) { segment in
                            if let name = segment.name, let id = segment.id {
                                Button {
                                    viewStore.send(.toggleRoom(id))
                                } label: {
                                    HStack {
                                        Text(name)
                                        Spacer()
                                        if viewStore.api.rooms.contains(id) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 44)
                }
                .toolbar(content: {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            viewStore.send(.startCleaning)
                        } label: {
                            Text("Start")
                        }
                    }
                })
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
                        }
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom))
                    }
                    .edgesIgnoringSafeArea(.horizontal)
                    .edgesIgnoringSafeArea(.bottom)
                )
            }
        }
    }
}

struct SegmentList_Previews: PreviewProvider {
    static var previews: some View {
        SegmentList(store: Main.previewStoreHome)
    }
}
