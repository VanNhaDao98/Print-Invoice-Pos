//
//  PrintData.swift
//  Printer-NhaDv
//
//  Created by Dao Van Nha on 22/12/24.
//

import Foundation
import UIKit

public protocol PrintDataConvert {
    func printData() -> Data
}

public enum PrintData {
    case image(UIImage)
    case text(String)
    case data(Data)
}

extension PrintData: PrintDataConvert {
    public func printData() -> Data {
        switch self {
        case .image(let uIImage):
            return uIImage.convertToData()
        case .text(let string):
            return string.data(using: .utf8) ?? Data()
        case .data(let data):
            return data
        }
    }
}

private extension UIImage {
    func convertToData() -> Data {
        let widthInPixels = Int(size.width)
        let heightInPixels = Int(size.height)
        
        let widthLSB: UInt8 = (UInt8(widthInPixels & 0xFF))
        let widthMSB: UInt8 = (UInt8((widthInPixels >> 8) & 0xFF))
        let imageBits = pixelData() ?? []
        
        var printData: Data = Data()
        
        let imageModeCommand = EscPosCommand.selectBitImageMode(widthLSB: widthLSB, widthMSB: widthMSB).data()
        
        var offset = 0
        
        while offset < heightInPixels {
            printData.append(imageModeCommand)
            
            var imageDataLineIndex = 0
            var imageDataLine = [UInt8](repeating: 0, count: 3 * widthInPixels)
            
            for x in 0..<widthInPixels {
                
                // Remember, 24 dots = 24 bits = 3 bytes.
                // The 'k' variable keeps track of which of those
                // three bytes that we're currently scribbling into.
                for k in 0..<3 {
                    var slice: UInt8 = 0
                    
                    // A byte is 8 bits. The 'b' variable keeps track
                    // of which bit in the byte we're recording.
                    for b in 0..<8 {
                        // Calculate the y position that we're currently
                        // trying to draw. We take our offset, divide it
                        // by 8 so we're talking about the y offset in
                        // terms of bytes, add our current 'k' byte
                        // offset to that, multiple by 8 to get it in terms
                        // of bits again, and add our bit offset to it.
                        let y = (((offset / 8) + k) * 8) + b
                        
                        // Calculate the location of the pixel we want in the bit array.
                        // It'll be at (y * width) + x.
                        let i = (y * widthInPixels) + x
                        
                        // If the image (or this stripe of the image)
                        // is shorter than 24 dots, pad with zero.
                        var v = false
                        
                        if i < imageBits.count {
                            //                                v = imageBits[i] <=  127;
                            v = self.shouldPrintColor(imageBits[i])
                        }
                        
                        // Finally, store our bit in the byte that we're currently
                        // scribbling to. Our current 'b' is actually the exact
                        // opposite of where we want it to be in the byte, so
                        // subtract it from 7, shift our bit into place in a temp
                        // byte, and OR it with the target byte to get it into there.
                        slice |= ((v ? 1 : 0) << (7 - b))
                    }
                    imageDataLine[imageDataLineIndex + k] = slice
                }
                imageDataLineIndex += 3
            }
            printData.append(contentsOf: imageDataLine)
            
            offset += 24
            printData.append(EscPosCommand.lineFeed().data())
        }
        
        return printData
    }
    
    private func shouldPrintColor(_ col: UInt32) -> Bool {
        let threshold = 127
        let a = (col >> 24) & 0xff
        if a != 0xff {// Ignore transparencies
            return false
        }
        let r = (col >> 16) & 0xff
        let g = (col >> 8) & 0xff
        let b = col & 0xff
        
        let newR = 0.3 * Double(r)
        let newG = 0.59 * Double(g)
        let newB = 0.11 * Double(b)
        let luminance = Int(newR + newG + newB)
        
        return luminance < threshold
    }
    
    func pixelData() -> [UInt32]? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        let height = Int(self.size.height)
        let width = Int(self.size.width)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerRow = 4 * width
        let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        | CGImageAlphaInfo.premultipliedLast.rawValue
        & CGBitmapInfo.alphaInfoMask.rawValue
        
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo),
              let rawPointer = context.data else {
            return nil
        }
        
        let pixelBuffer = rawPointer.bindMemory(to: UInt32.self, capacity: width * height)
        context.draw(cgImage, in: CGRect(origin: .zero, size: self.size))
        
        return Array(UnsafeBufferPointer(start: pixelBuffer, count: width * height))
    }
}
