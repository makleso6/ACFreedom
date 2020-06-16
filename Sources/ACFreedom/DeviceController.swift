//
//  DeviceController.swift
//  ACFreedom
//
//  Created by Maksim Kolesnik on 10.05.2020.
//

import Foundation
import NIO

public final class DeviceController {
    let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func discover() {
        
        guard let ipAdress = networkService.ipAddress else { return }
        guard let port = networkService.port else { return }

        var buffer: ByteBuffer = .init(.init([UInt8].init(repeating: 0, count: 40)))
        let date = Date()
        
        let timezone = TimeZone.current.secondsFromGMT() / -3600
        buffer.setInteger(UInt32(timezone), at: 0, endianness: .little, as: UInt32.self)
        
        if (timezone < 0) {
            buffer.setInteger(UInt32(0xff + timezone - 1), at: 0x08, endianness: .little, as: UInt32.self)
            buffer.setInteger(0xff, at: 0x09, endianness: .little, as: UInt32.self)
            buffer.setInteger(0xff, at: 0x0a, endianness: .little, as: UInt32.self)
            buffer.setInteger(0xff, at: 0x0b, endianness: .little, as: UInt32.self)
        } else {
            buffer.setInteger(UInt32(0xff + timezone - 1), at: 0x08, endianness: .little, as: UInt32.self)
            buffer.setInteger(0xff, at: 0x09, endianness: .little, as: UInt32.self)
            buffer.setInteger(0xff, at: 0x0a, endianness: .little, as: UInt32.self)
            buffer.setInteger(0xff, at: 0x0b, endianness: .little, as: UInt32.self)
        }
        
        let year = Calendar.current.component(.year, from: date)
        buffer.setInteger(UInt32(year & 0xff), at: 0x0c, endianness: .little, as: UInt32.self)
        buffer.setInteger(UInt32(year >> 8), at: 0x0c, endianness: .little, as: UInt32.self)
        
        let minute = Calendar.current.component(.minute, from: date)
        buffer.setInteger(UInt8(minute), at: 0x0e, endianness: .little, as: UInt8.self)

        let hour = Calendar.current.component(.hour, from: date)
        buffer.setInteger(UInt8(hour), at: 0x0f, endianness: .little, as: UInt8.self)
        
        buffer.setInteger(UInt8(year % 100), at: 0x10, endianness: .little, as: UInt8.self)

//        let second = Calendar.current.component(.second, from: date)
//        buffer.setInteger(UInt8(second), at: 6, endianness: .little, as: UInt8.self)

        let weekday = Calendar.current.component(.weekday, from: date) - 1
        buffer.setInteger(UInt8(weekday), at: 0x11, endianness: .little, as: UInt8.self)

        let day = Calendar.current.component(.day, from: date)
        buffer.setInteger(UInt8(day), at: 0x12, endianness: .little, as: UInt8.self)

        let month = Calendar.current.component(.month, from: date) - 1
        buffer.setInteger(UInt8(month), at: 0x13, endianness: .little, as: UInt8.self)

        let components = ipAdress.split(separator: ".").compactMap({ UInt8($0) })
        buffer.setInteger(components[0], at: 0x18, endianness: .little, as: UInt8.self)
        buffer.setInteger(components[1], at: 0x19, endianness: .little, as: UInt8.self)
        buffer.setInteger(components[2], at: 0x1a, endianness: .little, as: UInt8.self)
        buffer.setInteger(components[3], at: 0x1b, endianness: .little, as: UInt8.self)

        buffer.setInteger(UInt8(port & 0xff), at: 0x1c, endianness: .little, as: UInt8.self)
        buffer.setInteger(UInt8(port >> 8), at: 0x1d, endianness: .little, as: UInt8.self)

//        buffer.capacity
        var checksum = buffer.readableBytesView.reduce(Int(0xbeaf), { Int($0) + Int($1) })
//        for (var i = 0; i < packet.length; i++) {
//            checksum += packet[i];
//        }
        checksum = checksum & 0xffff
//        packet[0x20] = checksum & 0xff;
//        packet[0x21] = checksum >> 8;
        
    }
    
    func send() {
        
    }
}
