//
//  StatusItemView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import SwiftUI
import SwiftUIVisualEffects

struct StatusItemView: View {

    @State var iconName: String
    @State var label: String
    @State var value: String
    @State var unit: String

    var body: some View {
        Button(action: {}) {
            VStack {
                VStack {
                    Image(systemName: iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color("blue"))
                }
                .frame(width: 36, height: 36)
                .padding(.top, 24)
                .padding(.bottom, 24)

                VStack(spacing: 4) {
                    HStack {
                        Spacer()
                    }
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(value)
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(Color("blue"))
                            .fixedSize(horizontal: true, vertical: false)
                        Text(unit)
                            .font(.system(size: 14, weight: .bold, design: .default))
                            .foregroundColor(Color("blue"))
                    }
                    .fixedSize(horizontal: true, vertical: false)

                    Text(label)
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(Color(.label))
                        .fixedSize(horizontal: true, vertical: false)
                        .vibrancyEffect()
                }
                .padding(.bottom, 16)
            }
        }
        // .background(BlurEffect())
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal, 4)
        .shadow(color: Color.black.opacity(0.05), radius: 10.0, x: 15, y: 15)
        .shadow(color: Color.white.opacity(0.4), radius: 7.5, x: -5, y: -5)
    }
}

struct StatusItemView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            StatusItemView(iconName: "battery.100.bolt", label: "Battery", value: "100", unit: "%")
            StatusItemView(iconName: "stopwatch", label: "Clean Time", value: "52", unit: "min")
            StatusItemView(iconName: "square.dashed", label: "Clean Area", value: "97", unit: "qm")
        }
        .padding(.vertical, 100)
        .padding(.horizontal, 24)
        .background(Color(UIColor.secondarySystemBackground))
        .previewLayout(.fixed(width: 360, height: 280))
    }
}
