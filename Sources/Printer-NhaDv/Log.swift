//
//  Log.swift
//  Printer-NhaDv
//
//  Created by Dao Van Nha on 22/12/24.
//

import Foundation

public protocol Logging {
    func debug(_ msg: @autoclosure () -> Any)
    func error(_ msg: @autoclosure () -> Any)
}

internal class Log: Logging {
    func debug(_ msg: @autoclosure () -> Any) {
        Swift.print(Date(), "[DEBUG]", msg())
    }
    
    func error(_ msg: @autoclosure () -> Any) {
        Swift.print(Date(), "[ERROR]", msg())
    }
}


