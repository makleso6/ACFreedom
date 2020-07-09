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
            do {
//                print("capacity: ", addressedEnvelope.data.readableBytesView.count)
//                print("readableBytesView ", addressedEnvelope.data.readableBytesView.map({ $0 }))
//                let bytes = addressedEnvelope.data.readableBytesView.map({ $0 })
//
//                print("Device", bytes[0x34] | bytes[0x35] << 8)
//                print("Device", bytes[0x34...0x35].hexa)
//                print("name", String.init(data: Data(bytes[0x34...0x35].reversed()), encoding: .utf8)!)
//
//                print("mac start")
//                for i in 58...63 {
//                    print(bytes[i])
//                }
//
//                print("mac end")
//                print("mac", bytes[58...63].reversed().hexa)
//                print("name", String.init(data: Data(bytes[64...127]), encoding: .utf8)!)

//                addressedEnvelope.data.read
            } catch {
                
            }
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

extension Sequence where Element == UInt8 {
    var data: Data { .init(self) }
    var hexa: String { map { .init(format: "%02x", $0) }.joined() }
    var deca: String { map { .init(format: "%02x", $0) }.joined() }
}
