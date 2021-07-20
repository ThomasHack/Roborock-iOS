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
        ProgressView("\(value)", value: Float(value), total: Float(100))
            .progressViewStyle(CircularProgressViewStyle())
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

struct BatteryTileView_Previews: PreviewProvider {
    static var previews: some View {
        BatteryTileView(value: 100)
            .previewLayout(.fixed(width: 50, height: 50))
    }
}
