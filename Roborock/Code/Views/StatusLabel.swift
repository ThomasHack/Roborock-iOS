//
//  StatusLabel.swift
//  Roborock
//
//  Created by Hack, Thomas on 25.03.24.
//

import SwiftUI

struct StatusLabel: View {
    var label: String
    var unit: String
    var value: String

    var body: some View {
        VStack {
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text(value)
                    .font(.system(size: 16))
                Text(LocalizedStringKey(unit))
                    .font(.system(size: 12))
            }
            Text(LocalizedStringKey(label))
                .font(.system(size: 12, weight: .light))
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    StatusLabel(label: "", unit: "", value: "")
}
