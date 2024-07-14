//
//  OverlaySheet.swift
//  Roborock
//
//  Created by Hack, Thomas on 26.03.24.
//

import SwiftUI

struct OverlaySheet<Content: View>: View {
    var content: () -> Content
    @Binding var isExpanded: Bool
    @State private var offset: CGFloat = 0
    @GestureState private var startOffset: CGFloat?

    private let minOffset: CGFloat = 60
    private let maxOffset: CGFloat = 325

    init(isExpanded: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self._isExpanded = isExpanded
        self.offset = isExpanded.wrappedValue ? 60 : 325
    }

    var swipe: some Gesture {
        DragGesture()
            .onChanged { value in
                var newOffset = startOffset ?? offset
                newOffset += value.translation.height
                offset = max(newOffset, 0)
            }
            .onEnded { value in
                let drag = max(value.translation.height, value.predictedEndTranslation.height)
                let midOffset = (minOffset + maxOffset) / 2
                let newOffset = drag < midOffset ? minOffset : maxOffset
                withAnimation(Animation.spring()) {
                    isExpanded = newOffset == minOffset
                    offset = newOffset
                }
            }
            .updating($startOffset) { _, startOffset, _ in
                startOffset = startOffset ?? offset // 2
            }
    }

    var body: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 40, height: 4)
                .foregroundStyle(.thinMaterial)
            content()
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 25)
        .frame(height: 450)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .offset(y: offset)
        .gesture(swipe)
    }
}

#Preview {
    OverlaySheet(isExpanded: .constant(true)) {
        Text("")
    }
}
