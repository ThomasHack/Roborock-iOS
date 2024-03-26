//
//  UIEdgeInsets+SafeAreaInsets.swift
//  Roborock
//
//  Created by Hack, Thomas on 25.03.24.
//

import UIKit

extension UIEdgeInsets {
    static var safeAreaInsets: UIEdgeInsets {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return .zero }
        return keyWindow.safeAreaInsets
    }
}
