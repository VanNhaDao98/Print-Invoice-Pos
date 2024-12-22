//
//  PrintCommandBuider.swift
//  Printer-NhaDv
//
//  Created by Dao Van Nha on 22/12/24.
//

import Foundation

class PrintCommandBuider {
    private var commands: [EscPosCommand] = []
    private var numberOfCopies: Int
    
    init(numberOfCopies: Int) {
        self.numberOfCopies = numberOfCopies
    }
    
    func add(_ command: EscPosCommand, if condition: Bool = true) -> Self {
        if condition {
            commands.append(command)
        }
        return self
    }
    
    func build() -> Data {
        let printData = Data(commands.map({ $0.data() }).joined() )
        
        var allData = Data()
        
        for _ in 1...numberOfCopies {
            allData.append(printData)
        }
        
        return allData
    }
}
