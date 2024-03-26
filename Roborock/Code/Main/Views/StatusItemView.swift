//
//  StatusItemView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import SwiftUI

enum StatusItemValue {
    case int(Int)
    case double(Double)
}

struct StatusItemView: View {
    var label: String
    var unit: String
    var iconName: String
    var value: String

    var body: some View {
        HStack(spacing: 0) {
            VStack {
                Image(systemName: iconName)
                    .font(.system(size: 12))
            }
            .padding(.trailing, 4)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(value)
                        .font(.system(size: 12, weight: .bold, design: .default))
                    Text(unit)
                        .font(.system(size: 10, weight: .bold, design: .default))
                }
                Text(LocalizedStringKey(label))
                    .font(.system(size: 10, weight: .regular, design: .default))
            }
            .foregroundColor(.primary)
        }
        .padding(4)
        .padding(.horizontal, 4)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    HStack {
        StatusItemView(label: "Battery", unit: "%", iconName: "battery.100.bolt", value: "100")
        StatusItemView(label: "Clean Time", unit: "min", iconName: "stopwatch", value: "52")
        StatusItemView(label: "Clean Area", unit: "qm", iconName: "square.dashed", value: "56.8")
    }
    .padding(.vertical, 100)
    .padding(.horizontal, 24)
    .background(Color(.secondarySystemBackground))
    .previewLayout(.fixed(width: 360, height: 280))
}
