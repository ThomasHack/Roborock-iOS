//
//  StatusView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import ComposableArchitecture
import RoborockApi
import SwiftUI

struct FanspeedSelection: View {
    let store: Store<Main.State, Main.Action>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack {
                Menu(content: {
                    ForEach(viewStore.fanspeeds.reversed(), id: \.self) { value in
                        Button {
                            viewStore.send(.apiAction(.setFanspeed(value)))
                        } label: {
                            HStack {
                                Text(value.label)
                                Spacer()
                                if viewStore.apiState.status?.fanPower == value.rawValue {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }, label: {
                    Image(systemName: "speedometer")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .padding(16)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                })
            }
        })
    }
}

struct FanspeedSelection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all)
            FanspeedSelection(store: Main.previewStore)
        }
    }
}
