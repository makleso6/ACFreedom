//
//  OutboundHandler.swift
//  ACFreedom
//
//  Created by Maksim Kolesnik on 16.06.2020.
//

import Foundation
import NIO

public protocol OutboundHandler: AnyObject {
    func recive(result: Result<(AddressedEnvelope<ByteBuffer>), Error>)
}
