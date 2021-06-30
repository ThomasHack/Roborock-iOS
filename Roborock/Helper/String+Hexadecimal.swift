//
//  String+Hexadecimal.swift
//  Roborock
//
//  Created by Hack, Thomas on 28.06.21.
//

import Foundation

extension StringProtocol {
    func dropping<S: StringProtocol>(prefix: S) -> SubSequence {
        hasPrefix(prefix) ? dropFirst(prefix.count) : self[...]
    }

    var decimal: Int {
        Int(dropping(prefix: "0x"), radix: 16) ?? 0
    }
}
