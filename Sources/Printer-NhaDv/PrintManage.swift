//
//  PrintManage.swift
//  Printer-NhaDv
//
//  Created by Dao Van Nha on 22/12/24.
//

import Foundation

private let PrinterTag: String = "[Printer]"

open class PrintManage {
    
    public static var log: Logging = Log()
    
    private var streamSocket: StreamSocket?
    
    private var socletBuilder: () throws -> StreamSocket
    
    public init(socletBuilder: @escaping () throws -> StreamSocket) {
        self.socletBuilder = socletBuilder
    }
    
    public func print(info:PrintInfomation,
                      printers: [Printer],
                      handle: @escaping (PrintError?) -> Void) {
        var uniquePrinters: [Printer] = []
        guard !printers.isEmpty else {
            PrintManage.log.debug("\(PrinterTag): empty printer")
            return
        }
        
        var errorPrinter: PrintError?
        var exit: Bool = false
        
        for printer in printers {
            if !uniquePrinters.contains(printer) {
                uniquePrinters.append(printer)
            }
        }
        
        let sem = DispatchSemaphore(value: 0)
        
        for printer in uniquePrinters where !exit {
            do {
                self.streamSocket = try socletBuilder()
            } catch {
                exit = true
                errorPrinter = .createSocketError(error)
                continue
            }
            
            connectToPritner(printer: printer) { result in
                switch result {
                case .success:
                    self.print(info: info) {
                        switch $0 {
                        case .success:
                            break
                        case .failure(let error):
                            errorPrinter = .printFail(printer, error)
                        }
                        
                        sem.signal()
                    }
                case .failure(let failure):
                    errorPrinter = .connectSocketError(failure)
                    sem.signal()
                }
            }
            
            sem.wait()
            
            disconnect(completion: { _ in })
        }
        
        DispatchQueue.main.async {
            handle(errorPrinter)
        }
    }
    
    public func connect(printer: Printer,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            streamSocket = try socletBuilder()
        } catch {
            completion(.failure(error))
        }
        
        streamSocket?.connect(host: printer.host, port: printer.port, completion: completion)
    }
    
    public func disconnect(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let streamSocket, streamSocket.isConnected else { return }
        
        if let address = streamSocket.connectedAddress {
            PrintManage.log.debug("\(PrinterTag): disconnect: \(address.host): \(address.port)")
        }
        
        streamSocket.disconnect(completion: completion)
    }
    
    private func writeData(data: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        PrintManage.log.debug("\(PrinterTag): data: \(Int(data.count / 1024)) KBs")
        streamSocket?.write(data: data, completion: { result in
            switch result {
            case .success:
                PrintManage.log.debug("\(PrinterTag): print success")
            case .failure(let failure):
                PrintManage.log.debug("\(PrinterTag): print fall : \(failure)")
            }
            
            completion(result)
        })
    }
    
    private func connectToPritner(printer: Printer,
                                  completion: @escaping (Result<Void, Error>) -> Void) {
        PrintManage.log.debug("\(PrinterTag): connecting to Printer: \(printer.debugDescription)")
        streamSocket?.connect(host: printer.host, port: printer.port, completion: { result in
            switch result {
            case .success:
                PrintManage.log.debug("\(PrinterTag): connected: \(printer.debugDescription)")
            case .failure(let failure):
                PrintManage.log.debug("\(PrinterTag): connected fail: \(printer.debugDescription) : \(failure)")
            }
            completion(result)
        })
    }
    
    private func print(info: PrintInfomation, completion: @escaping (Result<Void, Error>) -> Void) {
        let data = PrintCommandBuider(numberOfCopies: info.numberOfCopies)
            .add(.initialization())
            .add(.setLineSpacing(space: 24))
            .add(.raw(data: info.data.printData()))
            .add(.lineFeed(lines: 3))
            .add(.setLineSpacing(space: 30))
            .add(.cutPaper(mode: 65, n: 0))
            .add(.openDrawer(), if: info.openDrawer)
            .build()
        
        writeData(data: data, completion: completion)
    }
}


public enum PrintError: Error {
    case createSocketError(Error)
    case connectSocketError(Error)
    case printFail(Printer, Error)
}

extension PrintManage {
    
    public convenience init() {
        self.init(socletBuilder: { try SocketUtils.buildDefaultSocket() })
    }
    
    public static var shared: PrintManage = .init()
}
