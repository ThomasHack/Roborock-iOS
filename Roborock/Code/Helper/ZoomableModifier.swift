//
//  ZoomableModifier.swift
//  Roborock
//
//  Created by Hack, Thomas on 27.07.23.
//

import SwiftUI

public struct ZoomableModifier: ViewModifier {

    private enum ZoomState {
        case inactive
        case active(scale: CGFloat)

        var scale: CGFloat {
            switch self {
            case .active(let scale):
                return scale
            default:
                return 1.0
            }
        }
    }

    private var contentSize: CGSize
    private var min: CGFloat = 1.0
    private var max: CGFloat = 3.0
    private var showsIndicators = false

    @GestureState private var zoomState = ZoomState.inactive
    @State private var currentScale: CGFloat = 0.9

    /**
     Initializes an `ZoomableModifier`
     - parameter contentSize : The content size of the views.
     - parameter min : The minimum value that can be zoom out.
     - parameter max : The maximum value that can be zoom in.
     - parameter showsIndicators : A value that indicates whether the scroll view displays the scrollable component of the content offset, in a way that’s suitable for the platform.
     */
    public init(contentSize: CGSize,
                min: CGFloat = 1.0,
                max: CGFloat = 3.0,
                showsIndicators: Bool = false) {
        self.contentSize = contentSize
        self.min = min
        self.max = max
        self.showsIndicators = showsIndicators
    }

    var scale: CGFloat {
        currentScale * zoomState.scale
    }

    var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($zoomState) { value, state, _ in
                state = .active(scale: value)
            }
            .onEnded { value in
                var new = self.currentScale * value
                if new <= min { new = min }
                if new >= max { new = max }
                self.currentScale = new
            }
    }

    var doubleTapGesture: some Gesture {
        TapGesture(count: 2).onEnded {
            if scale == max, scale == min {
                currentScale = 1.0
            }
            if scale == 1.0 {
                currentScale = max
            }
            if scale <= min {
                currentScale = max
            } else if scale >= max {
                currentScale = min
            } else {
                currentScale = 1.0 // ((max - min) * 0.5 + min) < scale ? max : min
            }
        }
    }

    public func body(content: Content) -> some View {
        ScrollView([.horizontal, .vertical], showsIndicators: showsIndicators) {
            content
                .frame(width: contentSize.width * scale, height: contentSize.height * scale, alignment: .center)
                .scaleEffect(scale, anchor: .center)
        }
        .gesture(ExclusiveGesture(zoomGesture, doubleTapGesture))
        .animation(.easeInOut, value: scale)
    }
}
