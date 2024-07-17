//
//  StatusItemView.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 15.07.21.
//

import SwiftUI
import UIKit

struct StatusTileView: View {
    var iconName: String
    var label: String
    var unit: String
    var value: String

    var body: some View {
        HStack(spacing: 8) {
            VStack {
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
            }
            .padding(6)
            .background(Color("blue-primary"))
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 0) {
                Text(LocalizedStringKey(label))
                    .font(.system(size: 11, weight: .regular, design: .default))
                    .foregroundColor(Color.gray)

                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(value)
                        .font(.system(size: 15, weight: .bold, design: .default))
                    Text(unit)
                        .font(.system(size: 10, weight: .bold, design: .default))
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct StatusItemView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            VStack(spacing: 8) {
                StatusTileView(
                    iconName: "stopwatch",
                    label: "Clean Time",
                    unit: "h",
                    value: "00:52")

                StatusTileView(
                    iconName: "square.dashed",
                    label: "Clean Area",
                    unit: "qm",
                    value: "56.8")
            }
            .padding()
        }
        .previewLayout(.fixed(width: 110, height: 70))
    }
}
