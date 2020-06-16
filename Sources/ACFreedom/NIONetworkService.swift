//
//  NIONetworkService.swift
//  Miio
//
//  Created by Maksim Kolesnik on 05/02/2020.
//

import Foundation
import NIO
import Logging

public class NIONetworkService: NetworkService, Logable {
    public var ipAddress: String? {
        return channel.localAddress?.ipAddress
    }
    
    public var port: Int? {
        return channel.localAddress?.port
    }
    
    
    let group: EventLoopGroup
    let bootstrap: DatagramBootstrap
    let channel: Channel
    
    public init(numberOfThreads: Int = System.coreCount,
                handler: ChannelHandler) throws {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        bootstrap = DatagramBootstrap(group: group)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_BROADCAST), value: 1)
            .channelInitializer({ channel in
                channel.pipeline.addHandler(handler)
            })
        channel = try bootstrap.bind(to: .init(ipAddress: "0.0.0.0", port: 0)).wait()
    }

    
    public func send(data: Data, to ipAddress: String, port: Int) throws {
        var buffer = channel.allocator.buffer(capacity: data.count)
        buffer.writeBytes(data)
        let destAddress = try SocketAddress(ipAddress: ipAddress, port: port)
        channel
            .writeAndFlush(AddressedEnvelope(remoteAddress: destAddress, data: buffer))
            .map({
                NIONetworkService.loger.debug("message sent to \(destAddress)")
            })
            .whenFailure({ error in
                NIONetworkService.loger.error("message sent to \(destAddress)")
            })

    }
    
    public func send<S>(bytes: S, to ipAddress: String, port: Int) throws  where S : Sequence, S.Element == UInt8 {
        try send(data: .init(bytes), to: ipAddress, port: port)
    }
    
    public func stop() throws {
        channel.close(promise: nil)
        try group.syncShutdownGracefully()
    }
}
