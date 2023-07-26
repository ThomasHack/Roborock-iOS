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
        VStack {
            VStack {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(Color("blue-primary"))
            }
            .frame(height: 28)

            VStack {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(Color("blue-primary"))
                        .fixedSize(horizontal: true, vertical: false)
                    Text(unit)
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .foregroundColor(Color("blue-primary"))
                }

                Text(LocalizedStringKey(label))
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(Color(.secondaryLabel))
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(
            Color(.systemBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct StatusItemView_Previews: PreviewProvider {
    static var previews: some View {
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
}
