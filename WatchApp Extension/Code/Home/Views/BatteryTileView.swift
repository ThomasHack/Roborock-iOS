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
        VStack(spacing: 8) {
            ProgressView("\(value)", value: Float(value), total: Float(100))
                .progressViewStyle(CircularProgressViewStyle(tintColor: Color.green))
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 8)
    }
}

struct BatteryTileView_Previews: PreviewProvider {
    static var previews: some View {
        BatteryTileView(value: 100)
            .previewLayout(.fixed(width: 100, height: 100))
    }
}
