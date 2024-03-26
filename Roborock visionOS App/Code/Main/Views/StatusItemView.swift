//
//  StatusItemView.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 30.11.23.
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
        VStack {
            VStack {
                Image(systemName: iconName)
                    .font(.callout)
            }
            .frame(height: 28)

            VStack {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.headline)
                        .fixedSize(horizontal: true, vertical: false)
                    Text(unit)
                        .font(.caption2)
                }

                Text(LocalizedStringKey(label))
                    .font(.caption2)
                    .foregroundColor(Color(.systemGray))
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
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
    .previewLayout(.fixed(width: 360, height: 280))
}
