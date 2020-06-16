//
//  NetworkService.swift
//  Miio
//
//  Created by Maksim Kolesnik on 05/02/2020.
//

import Foundation

public protocol NetworkService {
    
    var ipAddress: String? { get }
    var port: Int? { get }
    
    func send(data: Data, to ipAddress: String, port: Int) throws
    func send<S>(bytes: S, to ipAddress: String, port: Int) throws where S : Sequence, S.Element == UInt8
}
