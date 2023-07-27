//
//  ZoomableView.swift
//  Roborock
//
//  Created by Hack, Thomas on 27.07.23.
//

import SwiftUI

public struct ZoomableView<Content>: View where Content: View {
    private var min: CGFloat = 1.0
    private var max: CGFloat = 3.0
    private var showsIndicators = false

    @ViewBuilder private var content: () -> Content

    public init(min: CGFloat = 1.0,
                max: CGFloat = 3.0,
                showsIndicators: Bool = false,
                @ViewBuilder content: @escaping () -> Content) {
        self.min = min
        self.max = max
        self.showsIndicators = showsIndicators
        self.content = content
    }

    public var body: some View {
        GeometryReader { proxy in
            content()
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
                .contentShape(Rectangle())
                .modifier(ZoomableModifier(contentSize: proxy.size, min: min, max: max, showsIndicators: showsIndicators))
        }
    }
}
