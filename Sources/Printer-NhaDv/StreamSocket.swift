//
//  StreamSocket.swift
//  Printer-NhaDv
//
//  Created by Dao Van Nha on 22/12/24.
//

import Foundation
import Socket

public protocol StreamSocket {
    
    var isConnected: Bool { get }
    
    var connectedAddress: (host: String, port: Int)? { get }
    
    func write(data: Data, completion: @escaping (Result<Void, Error>) -> Void)
    
    func connect(host: String, port: Int, completion: @escaping (Result<Void, Error>) -> Void)
    
    func disconnect(completion: @escaping (Result<Void, Error>) -> Void)
    
}

open class StreamSocketImpl: StreamSocket {
    
    private var socket: Socket
    
    private var socketQueue: DispatchQueue
    
    private var callbackQueue: DispatchQueue
    
    init(socketQueue: DispatchQueue, callbackQueue: DispatchQueue) throws {
        self.socket = try .create()
        self.socketQueue = socketQueue
        self.callbackQueue = callbackQueue
    }
    
    
    public var isConnected: Bool {
        socket.isConnected
    }
    
    public var connectedAddress: (host: String, port: Int)? {
        isConnected ? (socket.remoteHostname, Int(socket.remotePort)) : nil
    }
    
    public func write(data: Data, completion: @escaping (Result<Void, any Error>) -> Void) {
        socketQueue.async {
            do {
                try self.socket.write(from: data)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func connect(host: String, port: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        socketQueue.async {
            do {
                try self.socket.connect(to: host, port: Int32(port), timeout: 30 * 1000)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func disconnect(completion: @escaping (Result<Void, any Error>) -> Void) {
        socketQueue.async {
            self.socket.close()
            completion(.success(()))
        }
    }

}

open class SocketUtils {
    public static func buildDefaultSocket() throws -> StreamSocket {
        try StreamSocketImpl(socketQueue: .global(), callbackQueue: .main)
    }
}
