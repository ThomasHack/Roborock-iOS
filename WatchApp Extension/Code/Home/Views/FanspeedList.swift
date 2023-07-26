//
//  FanspeedList.swift
//  FanspeedList
//
//  Created by Hack, Thomas on 20.07.21.
//

import ComposableArchitecture
import SwiftUI

struct FanspeedList: View {
    let store: StoreOf<Main>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            ScrollView {
                VStack {
                    ForEach(viewStore.fanspeeds, id: \.self) { value in
                        Button {
                            viewStore.send(.setFanspeed(value))
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
                }
            }
        }
    }
}

struct FanspeedList_Previews: PreviewProvider {
    static var previews: some View {
        FanspeedList(store: Main.previewStore)
    }
}
