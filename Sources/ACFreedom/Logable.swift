//
//  Logable.swift
//  Miio
//
//  Created by Maksim Kolesnik on 05/02/2020.
//

import Foundation
import Logging

public protocol Logable {
    var loger: Logger { get }
    static var loger: Logger { get }
}

extension Logable {
    public var loger: Logger {
        var logger = Logger(label: String(describing: type(of: self)))
        logger.logLevel = Logger.Level.trace
        return logger
    }
    
    public static var loger: Logger {
        var logger = Logger(label: String(describing: type(of: self)))
        logger.logLevel = Logger.Level.trace
        return logger
    }

    
}
