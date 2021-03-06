//
//  BlurView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import SwiftUI
import UIKit

struct BlurView: UIViewRepresentable {
    typealias UIViewType = UIVisualEffectView

    let style: UIBlurEffect.Style

    init(style: UIBlurEffect.Style = .systemChromeMaterial) {
        self.style = style
    }

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: self.style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: self.style)
    }
}

struct VibrancyView: UIViewRepresentable {
    typealias UIViewType = UIVisualEffectView

    let style: UIVibrancyEffectStyle
    let blurEffect = UIBlurEffect(style: .systemChromeMaterial)

    init(style: UIVibrancyEffectStyle = .label) {
        self.style = style
    }

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect, style: self.style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIVibrancyEffect(blurEffect: blurEffect, style: self.style)
    }
}
