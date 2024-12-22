//
//  Printer.swift
//  Printer-NhaDv
//
//  Created by Dao Van Nha on 22/12/24.
//

import Foundation

public struct Printer: Equatable {
    public var host: String
    public var port: Int
    
    public init(host: String,
                port: Int) {
        self.host = host
        self.port = port
    }
}

extension Printer: CustomDebugStringConvertible {
    public var debugDescription: String {
        "host: \(host), port: \(port)"
    }
}
