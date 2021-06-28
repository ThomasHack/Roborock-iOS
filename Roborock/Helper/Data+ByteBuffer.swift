//
//  Data+ByteBuffer.swift
//  Roborock
//
//  Created by Hack, Thomas on 28.06.21.
//

import Foundation

extension Data {
    public func getBytes(position: Int, length: Int) -> Data? {
        if position >= 0 && position + length <= self.count {
            return self.subdata(in: position..<position + length)
        }
        return nil
    }

    public func getInt16(position: Int) -> Int {
        return Int(self.subdata(in: position..<position + MemoryLayout<Int16>.size).withUnsafeBytes { $0.load(as: UInt16.self) })
    }

    public func getInt32(position: Int) -> Int {
        return Int(self.subdata(in: position..<position + MemoryLayout<Int32>.size).withUnsafeBytes { $0.load(as:  UInt32.self)})
    }
}
