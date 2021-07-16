//
//  PaginatedView.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 14.07.21.
//

import SwiftUI

struct PaginatedView<Content: View>: View {
    @Binding var currentIndex: Int
    @GestureState private var translation: CGFloat = 0

    let pageCount: Int
    let content: Content

    init(pageCount: Int, currentIndex: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                self.content.frame(width: geometry.size.width)
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .offset(x: -CGFloat(self.currentIndex) * geometry.size.width)
            .offset(x: self.translation)
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                state = value.translation.width
            }
                    .onEnded { value in
                let offset = value.translation.width / geometry.size.width
                let newIndex = (CGFloat(self.currentIndex) - offset).rounded()
                self.currentIndex = min(max(Int(newIndex), 0), self.pageCount - 1)
            }
            )
        }
    }
}
