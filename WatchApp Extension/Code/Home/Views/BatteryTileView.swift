//
//  BatteryTileView.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 19.07.21.
//

import SwiftUI

struct BatteryTileView: View {
    @State var value: Int

    var body: some View {
        GeometryReader { geometry in
            ProgressView("\(value)", value: Float(value), total: Float(100))
                .progressViewStyle(CircularProgressViewStyle(tintColor: Color.green))
                .frame(width: geometry.size.width, height: geometry.size.height)
                .overlay(
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text("\(value)")
                            .font(.body)
                        Text("%")
                            .font(.system(size: 12))
                            .foregroundColor(Color.gray)
                    }
                )
        }
    }
}

struct BatteryTileView_Previews: PreviewProvider {
    static var previews: some View {
        BatteryTileView(value: 100)
            .previewLayout(.fixed(width: 100, height: 100))
    }
}
