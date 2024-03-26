//
//  SectionHeader.swift
//  Hyperion
//
//  Created by Hack, Thomas on 14.06.20.
//  Copyright © 2020 Hack, Thomas. All rights reserved.
//

import SwiftUI

struct SectionHeader: View {

    var text: String

    var body: some View {
        Text(LocalizedStringKey(text))
        .font(.system(size: 16.0, weight: .semibold))
    }
}

#Preview {
    SectionHeader(text: "Title")
}
