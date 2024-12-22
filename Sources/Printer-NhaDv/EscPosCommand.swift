//
//  File.swift
//  Printer-NhaDv
//
//  Created by Dao Van Nha on 22/12/24.
//

import Foundation

public struct EscPosCommand: RawRepresentable {

    public typealias RawValue = [UInt8]

    public let rawValue: [UInt8]

    public init(rawValue: [UInt8]) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: [UInt8]) {
        self.init(rawValue: rawValue)
    }
    
    public init(data: Data) {
        self.init(rawValue: [UInt8](data))
    }

    func data() -> Data {
        Data(rawValue)
    }
}

// ref: http://content.epson.de/fileadmin/content/files/RSD/downloads/escpos.pdf

//Control Commands
public extension EscPosCommand {
    
    static func raw(data: Data) -> EscPosCommand {
        EscPosCommand(data: data)
    }

    // Clears the data in the print buffer and resets the printer modes to the modes that were in effect when the power was turned on.
    static func initialization() -> EscPosCommand {
        EscPosCommand([27, 64])
    }

    // feeds n lines
    static func lineFeed(lines: Int = 1) -> EscPosCommand {
        return EscPosCommand(Array(repeating: 10, count: lines))
    }

    // Prints the data in the print buffer and feeds n lines.
    static func printAndFeed(lines: UInt8 = 1) -> EscPosCommand {
        return EscPosCommand([27, 100, lines])
    }

    static func feed(points: UInt8) -> EscPosCommand {
        return EscPosCommand([27, 74, points])
    }

    // Prints the data in the print buffer and feeds n lines in the reverse direction.
    static func printAndReverseFeed(lines: UInt8 = 1) -> EscPosCommand {
        return EscPosCommand([27, 101, lines])
    }

    // Turn emphasized mode on/off
    static func emphasize(mode: Bool) -> EscPosCommand {
        return EscPosCommand([27, 69, mode ? 1 : 0])
    }

    // Select character font
    static func font(_ n: UInt8) -> EscPosCommand {
        return EscPosCommand([27, 77, n])
    }

    // Selects the printing color specified by n
    static func color(n: UInt8) -> EscPosCommand {
        return EscPosCommand([27, 114, n])
    }

    // Turn white/black reverse printing mode on/off
    static func white_blackReverse(mode: Bool) -> EscPosCommand {
        return EscPosCommand([29, 66, mode ? 1 : 0])
    }

    // Aligns all the data in one line to the position specified by n as follows:
    static func justification(_ n: UInt8) -> EscPosCommand {
        return EscPosCommand([27, 97, n])
    }
    // Selects the character font and styles (emphasize, double-height, double-width, and underline) together.
    static func print(modes n: UInt8) -> EscPosCommand {
        return EscPosCommand([27, 33, n])
    }

    // Turns underline mode on or off
    static func underline(mode: UInt8) -> EscPosCommand {
        return EscPosCommand([27, 45, mode])
    }

    static func cutPaper(mode: UInt8, n: UInt8) -> EscPosCommand {
        return EscPosCommand([29, 86, mode, n])
    }

    static func selectBitImageMode(widthLSB: UInt8, widthMSB: UInt8) -> EscPosCommand {
        return EscPosCommand([0x1B, 0x2A, 33, widthLSB, widthMSB])
    }

    static func setLineSpacing(space: UInt8) -> EscPosCommand {
        return EscPosCommand([27, 51, space])
    }
    
    static func openDrawer() -> EscPosCommand {
        return EscPosCommand([27, 112, 48, 55, 121])
    }

    //    static func QRSetSize (point: UInt8 = 8) -> EscPosCommand {
    //        return EscPosCommand([29, 40, 107, 3, 0, 49, 67, point])
    //    }
    //
    //    static func QRSetRecoveryLevel() -> EscPosCommand {
    //        return  EscPosCommand(rawValue: [29, 40, 107, 3, 0, 49, 69, 51])
    //    }
    //
    //    static func QRGetReadyToStore(text: String) -> EscPosCommand {
    //
    //        let s  = text.count + 3
    //        let pl = s % 256
    //        let ph = s / 256
    //
    //        return EscPosCommand([29, 40, 107, UInt8(pl), UInt8(ph), 49, 80, 48])
    //    }
    //
    //    static func QRPrint() -> EscPosCommand {
    //        return EscPosCommand([29, 40, 107, 3, 0, 49, 81, 48])
    //    }
}

