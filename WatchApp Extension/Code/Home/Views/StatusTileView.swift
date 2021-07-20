//
//  StatusItemView.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 15.07.21.
//

import SwiftUI
import UIKit

struct StatusTileView: View {
    @State var iconName: String
    @State var label: String
    @State var unit: String
    @State var color: Color

    @Binding var value: String

    var body: some View {
        HStack(spacing: 8) {

            VStack {
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
            }
            .padding(4)
            .background(color)
            .clipShape(Circle())

            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text(value)
                    .font(.system(size: 12, weight: .bold, design: .default))
                Text(unit)
                    .font(.system(size: 9, weight: .bold, design: .default))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatusItemView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                StatusTileView(iconName: "stopwatch", label: "Clean Time", unit: "h", color: Color.orange, value: .constant("00:52"))
                StatusTileView(iconName: "square.dashed", label: "Clean Area", unit: "qm", color: Color.green, value: .constant("56.8"))
            }
        }
        .previewLayout(.fixed(width: 200, height: 200))
    }
}
