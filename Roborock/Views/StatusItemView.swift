//
//  StatusItemView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import SwiftUI

struct StatusItemView: View {

    @State var iconName: String
    @State var label: String
    @State var value: Int

    var body: some View {
        Button(action: {}) {
            VStack {
                VStack {
                    Image(systemName: iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.blue)
                }
                .frame(width: 36, height: 36)
                .padding(.vertical, 16)
                VStack(spacing: 4) {
                    HStack {
                        Spacer()
                    }
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text("\(value)")
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.blue)
                            .fixedSize(horizontal: true, vertical: false)
                        Text("%")
                            .font(.system(size: 14, weight: .bold, design: .default))
                            .foregroundColor(.blue)
                    }
                    .fixedSize(horizontal: true, vertical: false)

                    Text(label)
                        .font(.system(size: 14, weight: .light, design: .default))
                        .foregroundColor(Color(.label))
                        .fixedSize(horizontal: true, vertical: false)
                }
                .padding(.bottom, 16)
            }
        }
        .background(Color.white.opacity(0.5))
        .background(BlurView().opacity(0.2))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.systemBackground), lineWidth: 2))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 4)
        .shadow(color: Color.black.opacity(0.05), radius: 20.0, x: 10, y: 10)
    }
}

struct StatusItemView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            StatusItemView(iconName: "battery.100.bolt", label: "Battery", value: 100)
            StatusItemView(iconName: "stopwatch", label: "Clean Time", value: 52)
            StatusItemView(iconName: "square.dashed", label: "Clean Area", value: 97)
        }
        .background(Color(UIColor.secondarySystemBackground))
        .previewLayout(.fixed(width: 320, height: 200))
    }
}
