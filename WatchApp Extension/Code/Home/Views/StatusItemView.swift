//
//  StatusItemView.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 15.07.21.
//

import SwiftUI
import UIKit

struct StatusItemView: View {
    @State var iconName: String
    @State var label: String
    @State var unit: String
    @State var color: Color

    @Binding var value: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                VStack {
                    Image(systemName: iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                }
                .padding(6)
                .background(color)
                .clipShape(Circle())

                VStack {
                    Text(label)
                        .font(.headline)
                    Spacer(minLength: 0)
                }
                Spacer()

                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(value)
                        .font(.body)
                    Text(unit)
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct StatusItemView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            StatusItemView(iconName: "battery.100.bolt", label: "Battery", unit: "%", color: Color.red, value: .constant("100"))
            // StatusItemView(iconName: "stopwatch", label: "Clean Time", value: 52, unit: "min")
            // StatusItemView(iconName: "square.dashed", label: "Clean Area", value: 56.8, unit: "qm")
        }
        .padding(.vertical, 100)
        .padding(.horizontal, 24)
        .previewLayout(.fixed(width: 360, height: 280))
    }
}
