//
//  StatusItemView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import SwiftUI

struct AttachmentItemView: View {
    var label: String
    var iconName: String
    var attached: Bool

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .frame(height: 36)
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(LocalizedStringKey(String("roborock.attachment.\(label)")))
                        .font(.system(size: 14, weight: .bold, design: .default))
                }
            }
            .foregroundColor(Color("blue-primary"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(.regularMaterial)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)

            HStack {
                Text(attached ? "attached" : "not attached")
                    .font(.system(size: 12, weight: .regular, design: .default))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal)
            .foregroundColor(Color(.secondaryLabel))
            .background(Color(attached ? .attachedColor : .notAttachedColor).opacity(0.5))
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    HStack {
        AttachmentItemView(label: "Mop", iconName: "battery.100.bolt", attached: true)
        AttachmentItemView(label: "Watertank", iconName: "stopwatch", attached: false)
    }
    .padding(.vertical, 100)
    .padding(.horizontal, 24)
    .background(Color(.secondarySystemBackground))
    .previewLayout(.fixed(width: 360, height: 280))
}
