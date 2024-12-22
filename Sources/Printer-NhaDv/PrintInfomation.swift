//
//  PrintInfomation.swift
//  Printer-NhaDv
//
//  Created by Dao Van Nha on 22/12/24.
//

import Foundation

public class PrintInfomation {
    public let data: PrintDataConvert
    public let numberOfCopies: Int
    public let openDrawer: Bool
    
    public init(data: PrintDataConvert,
         numberOfCopies: Int,
         openDrawer: Bool) {
        self.data = data
        self.numberOfCopies = numberOfCopies
        self.openDrawer = openDrawer
    }
}
