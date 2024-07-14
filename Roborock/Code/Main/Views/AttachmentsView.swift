//
//  AttachmentsView.swift
//  Roborock
//
//  Created by Hack, Thomas on 26.03.24.
//

import ComposableArchitecture
import SwiftUI

struct AttachmentsView: View {
    @Bindable var store: StoreOf<Api>

    var body: some View {
        VStack(alignment: .leading) {
            Text("Attachments")
                .font(.system(size: 16, weight: .semibold))
            HStack {
                ForEach(store.attachments, id: \.self) { attachment in
                    StatusItemView(label: attachment.attached ? "Attached" : "Not attached",
                                   unit: "",
                                   iconName: attachment.icon,
                                   value: attachment.type.rawValue.capitalized
                    )
                }
                Spacer()
            }
        }
    }
}

#Preview {
    AttachmentsView(store: Api.previewStore)
}
