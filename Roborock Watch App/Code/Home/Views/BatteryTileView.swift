//
//  BatteryTileView.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 19.07.21.
//

import SwiftUI

struct BatteryTileView: View {
    var value: Int?

    var body: some View {
        ProgressView("\(value ?? 0)", value: Float(value ?? 0), total: Float(100))
            .progressViewStyle(CircularProgressViewStyle())
            .overlay(
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text("\(value ?? 0)")
                        .font(.system(size: 20, weight: .semibold))
                    Text("%")
                        .font(.system(size: 14))
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
