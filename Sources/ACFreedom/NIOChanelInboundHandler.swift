//
//  NIOChanelInboundHandler.swift
//  ACFreedom
//
//  Created by Maksim Kolesnik on 16.06.2020.
//

import NIO
import Logging
import Foundation

public final class NIOChanelInboundHandler: ChannelInboundHandler, Logable {
    
    public typealias InboundIn = AddressedEnvelope<ByteBuffer>
    public typealias OutboundOut = AddressedEnvelope<ByteBuffer>
    public typealias ResultType = Result<(AddressedEnvelope<ByteBuffer>), Error>
    public weak var outboundHandler: OutboundHandler?
    private var _data: NIOAny?
    public init() { }
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        self._data = data
//        let addressedEnvelope = unwrapInboundIn(data)
//        loger.debug("\(String(describing: addressedEnvelope.remoteAddress.ipAddress))")
//        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: { [weak self] in
//            self?
//                .outboundHandler?.recive(result: .success(addressedEnvelope))
//        })
    }

    public func channelReadComplete(context: ChannelHandlerContext) {
//        loger.debug("channelReadComplete")
        context.flush()
        
        if let data = _data {
            let addressedEnvelope = unwrapInboundIn(data)
            outboundHandler?.recive(result: .success(addressedEnvelope))
        }
        _data = nil
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        loger.error("\(error)")
        outboundHandler?.recive(result: .failure(error))
        context.close(promise: nil)
    }
}
