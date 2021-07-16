//
//  ContentView.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 13.07.21.
//

import ComposableArchitecture
import SwiftUI

struct MyProgressViewStyle: ProgressViewStyle {
    var strokeColor = Color.green
    var backgroundColor = Color.green.opacity(0.4)
    var strokeWidth = 3.0

    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0

        return ZStack {
            Circle()
                .stroke(backgroundColor, style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
                .rotationEffect(.degrees(-90))
            Circle()
                .trim(from: 0, to: CGFloat(fractionCompleted))
                .stroke(strokeColor, style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 26, height: 26, alignment: .center)
        .padding(2)
    }
}

struct HomeView: View {
    let store: Store<Home.State, Home.Action>

    @State private var currentPage = 0

    var body: some View {
        WithViewStore(self.store) { viewStore in
            if viewStore.status != nil {
                ScrollView {
                    VStack {
                        Text("State: \(viewStore.humanState)")
                            .font(.headline)

                        VStack(spacing: 0) {
                            HStack(spacing: 8) {
                                if let status = viewStore.status {
                                    VStack {
                                        // viewStore.battery, Float(status.battery)
                                        ProgressView("65", value: 65, total: Float(100))
                                            .progressViewStyle(MyProgressViewStyle())
                                    }
                                }

                                VStack {
                                    Text("Battery")
                                        .font(.headline)
                                    Spacer(minLength: 0)
                                }
                                Spacer()

                                VStack(alignment: .trailing, spacing: 0) {
                                    Text(viewStore.battery)
                                        .font(.body)
                                    Text("%")
                                        .font(.caption)
                                        .foregroundColor(Color.gray)
                                }
                            }
                            .padding(.bottom, 8)
                        }

                        StatusItemView(iconName: "stopwatch",
                                       label: "Clean Time",
                                       unit: "min",
                                       color: Color.orange,
                                       value: viewStore.binding(get: { $0.cleanTime }, send: Home.Action.none))

                        StatusItemView(iconName: "square.dashed",
                                       label: "Clean Area",
                                       unit: "qm",
                                       color: Color.blue,
                                       value: viewStore.binding(get: { $0.cleanArea }, send: Home.Action.none))
                    }
                }
            } else {
                VStack {
                    Spacer()
                    Text("Loading...")
                    Spacer()
                }
                .onAppear {
                    viewStore.send(.fetchStatus)
                    viewStore.send(.fetchSegments)
                }
            }
        }
        .navigationTitle("Status")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: Home.previewStore)
    }
}
