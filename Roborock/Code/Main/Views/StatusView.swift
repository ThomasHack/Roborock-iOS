//
//  StatusView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import ComposableArchitecture
import SwiftUI

struct StatusView: View {
    @Bindable var store: StoreOf<Api>

    var body: some View {
        VStack {
            HStack {
                ForEach(store.attachments, id: \.self) { attachment in
                    AttachmentItemView(label: attachment.type.rawValue,
                                       iconName: attachment.icon,
                                       attached: attachment.attached
                    )
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all)
        StatusView(store: Api.previewStore)
            .padding()
    }
}
