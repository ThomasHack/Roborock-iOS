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
            VStack {
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
            }
            .padding(6)
            .background(color)
            .clipShape(Circle())

            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text(value)
                    .font(.body)
                Text(unit)
                    .font(.system(size: 12))
                    .foregroundColor(Color.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color("secondarySystemBackground"))
        .cornerRadius(22)
    }
}

struct StatusItemView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                StatusItemView(iconName: "stopwatch", label: "Clean Time", unit: "min", color: Color.orange, value: .constant("52"))
                StatusItemView(iconName: "square.dashed", label: "Clean Area", unit: "qm", color: Color.green, value: .constant("56.8"))
            }
        }
        .previewLayout(.fixed(width: 200, height: 100))
    }
}
