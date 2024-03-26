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
    @Bindable var store: StoreOf<Main>

    var body: some View {
        if !store.apiState.segments.isEmpty {
            ScrollView {
                VStack {
                    ForEach(store.apiState.segments, id: \.self) { segment in
                        Button {
                            store.send(.toggleRoom(segment))
                        } label: {
                            HStack {
                                if store.apiState.selectedSegments.contains(segment) {
                                    let index = Int(store.apiState.selectedSegments.firstIndex(of: segment) ?? 0)
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

                                Text(segment.name ?? "-")
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
                            store.send(.startCleaning)
                        } label: {
                            Text("Start")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(store.apiState.selectedSegments.isEmpty)
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

struct SegmentList_Previews: PreviewProvider {
    static var previews: some View {
        SegmentList(store: Main.previewStore)
    }
}
