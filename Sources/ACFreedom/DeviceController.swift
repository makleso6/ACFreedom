//
//  DeviceController.swift
//  ACFreedom
//
//  Created by Maksim Kolesnik on 10.05.2020.
//

import Foundation
import NIO
import CryptoSwift

public enum Command: UInt8 {
    case authRequst = 0x65
    case authResponse = 0xe9
    case payload = 0xee
    case request = 0x6a
}


public enum State: UInt8 {
    case on = 1
    case off = 0
}

public enum VerticalFixation: UInt8 {
    case on = 0
    case off = 7
}

public enum HorizontalFixation: UInt8 {
    case on = 0
    case off = 7
}

public enum Fanspeed: UInt8 {
    case low = 3
    case medium = 2
    case high = 1
}

public enum Mode: UInt8 {
    case cooling  = 0b00000001
    case dry      = 0b00000010
    case heating  = 0b00000100
    case auto     = 0b00000000
    case fan      = 0b00000110
}



public struct ACDevice: Equatable {
    public var temperature: UInt8 = 24
    internal var auxTemperature: UInt8 {
        if temperature > 32 {
            return 24
        } else if temperature < 16 {
            return 8
        } else {
            return temperature - 8
        }
    }
    public var power: State = .on
    public var fanspeed: Fanspeed = .medium
    public var verticalFixation: VerticalFixation = .on
    public var horizontalFixation: HorizontalFixation = .on
    public var turbo: State = .off
    public var mute: State = .on
    public var mode: Mode = .cooling
    public var health: State = .off
    public var clean: State = .off
    public var display: State = .on
    public var mildew: State = .off
    public var sleep: State = .off
}

public struct AUXDevice {
    public var id: [UInt8] = .init(repeating: 0, count: 4)
    public var mac: [UInt8]
    public var ip: String
    public var key: [UInt8] = Conts.defaultKey
}

public final class DeviceController: OutboundHandler {
    
    private var auxDevice: AUXDevice
    public var device: ACDevice = .init() {
        didSet {
            if device != oldValue {
                try? update()
            }
        }
    }
    private let networkService: AUXNetworkService
    
    public init(networkService: AUXNetworkService,
                mac: [UInt8],
                ip: String) {
        self.auxDevice = .init(mac: mac, ip: ip)
        self.networkService = networkService
    }
    
    func update() throws {
        var payload: [UInt8] = .init(repeating: 0, count: 23);
        payload[0] = 0xbb
        payload[1] = 0x00
        payload[2] = 0x06  //# Send command, seems like 07 is response
        payload[3] = 0x80
        payload[4] = 0x00
        payload[5] = 0x00
        payload[6] = 0x0f  //# Set status .. #02 -> get info?
        payload[7] = 0x00
        payload[8] = 0x01
        payload[9] = 0x01
        payload[10] = 0b00000000 | device.auxTemperature << 3 | device.verticalFixation.rawValue
//        payload[10] = 0b00000000 | 8 << 3 | 0
        payload[11] = 0b00000000 | device.horizontalFixation.rawValue << 5//self.status['fixation_h'] <<5
        payload[12] = 0b00001111 | 0 << 7   //# bit 1:  0.5  #bit   if 0b?1 then nothing done....  last 6 is some sort of packet_id
        payload[13] = 0b00000000 | device.fanspeed.rawValue << 5//self.status['fanspeed'] << 5
        payload[14] = 0b00000000 | device.turbo.rawValue << 6 | device.mute.rawValue << 7 //self.status['turbo'] << 6 | self.status['mute'] << 7
        payload[15] = 0b00000000 | device.mode.rawValue << 5 | device.sleep.rawValue << 2 //self.status['mode'] << 5 | self.status['sleep'] << 2
        payload[16] = 0b00000000
        payload[17] = 0x00
        payload[18] = 0b00000000 | device.power.rawValue << 5 | device.health.rawValue << 1 | device.clean.rawValue << 2//self.status['power']<<5 | self.status['health'] << 1 | self.status['clean'] << 2
        payload[19] = 0x00
        payload[20] = 0b00000000 | device.display.rawValue << 4 | device.mildew.rawValue << 3// self.status['display'] <<4  | self.status['mildew'] << 3
        payload[21] = 0b00000000
        payload[22] = 0b00000000
        
        var request: [UInt8] = .init(repeating: 0, count: 32)
        request[0] = UInt8(payload.count) + 2  
        request.replaceSubrange(Range<Int>.init(uncheckedBounds: (2, 25)), with: payload)
        
        let crc = checksum(data: payload)
        
        request[payload.count + 2] = UInt8(((crc >> 8) & 0xFF))
        request[payload.count + 3] = UInt8(crc & 0xFF)
        //[25, 0, 187, 0, 6, 128, 0, 0, 15, 0, 1, 1, 135, 36, 51, 32, 94, 32, 0, 0, 32, 0, 16, 0, 0, 230, 24, 0, 0, 0, 0, 0],
        
        try networkService.send(to: auxDevice.ip,
                                port: 80,
                                command: 0x6a,
                                payload: request,
                                key: auxDevice.key,
                                iv: Conts.defaultIV,
                                id: auxDevice.id,
                                mac: auxDevice.mac)
    }
    
    public func getInfo() throws {
        try networkService.send(to: auxDevice.ip,
                                port: 80,
                                command: 0x6a,
                                payload: [12, 0, 187, 0, 6, 128, 0, 0, 2, 0, 17, 1, 43, 126, 0, 0],
                                key: auxDevice.key,
                                iv: Conts.defaultIV,
                                id: auxDevice.id,
                                mac: auxDevice.mac)
    }
    
    public func auth() throws {
        var payload: [UInt8] = .init(repeating: 0, count: 80);
        payload[0x04] = 0x31
        payload[0x05] = 0x31
        payload[0x06] = 0x31
        payload[0x07] = 0x31
        payload[0x08] = 0x31
        payload[0x09] = 0x31
        payload[0x0a] = 0x31
        payload[0x0b] = 0x31
        payload[0x0c] = 0x31
        payload[0x0d] = 0x31
        payload[0x0e] = 0x31
        payload[0x0f] = 0x31
        payload[0x10] = 0x31
        payload[0x11] = 0x31
        payload[0x12] = 0x31
        payload[0x1e] = 0x01
        payload[0x2d] = 0x01
        payload[0x30] = Character("T").asciiValue ?? 0
        payload[0x31] = Character("e").asciiValue ?? 0
        payload[0x32] = Character("s").asciiValue ?? 0
        payload[0x33] = Character("t").asciiValue ?? 0
        payload[0x34] = Character(" ").asciiValue ?? 0
        payload[0x35] = Character(" ").asciiValue ?? 0
        payload[0x36] = Character("1").asciiValue ?? 0
        
        try networkService.send(to: auxDevice.ip,
                                port: 80,
                                command: 0x65,
                                payload: payload,
                                key: auxDevice.key,
                                iv: Conts.defaultIV,
                                id: auxDevice.id,
                                mac: auxDevice.mac)
    }
    
    public func recive(result: Result<(AddressedEnvelope<ByteBuffer>), Error>) {
        switch result {
        case .success(let addressedEnvelope):
            let response = addressedEnvelope.data.readableBytesView.map({ $0 })
            let bytes = response.suffix(response.count - 0x38)
            do {
                let data = try AES(key: auxDevice.key, blockMode: CBC(iv: Conts.defaultIV), padding: .noPadding).decrypt(bytes)
                
                let command = response[0x26];
                print("command", command)
                if command == 0xe9 {
                    auxDevice.key = Array(data[4...19])
                    print(auxDevice.key)
                    auxDevice.id = Array(data[0...3])
                    print(auxDevice.id)
                    
                } else if command == 0xee {
                    print("response")
                    print(data)
                }
                
            } catch {
                print(error)
            }
            
        case .failure(let error):
            print(error)
        }
        
    }
    
    func checksum(data: [UInt8]) -> Int {
        
        var mutableData = data
        let len = mutableData.count
        if len % 2 == 1 {
            mutableData.append(0)
        }
        var sum = 0
        var i = 0
        
        while i <= len {
            sum += (Int(mutableData[i]) << 8) + Int(mutableData[i + 1])
            i += 2
        }
        sum = (sum >> 16) + (sum & 0xFFFF)
        sum = ~sum & 0xFFFF
        
        return sum
    }
    
}

public protocol AUXNetworkService {
    func send(to ipAddress: String,
              port: Int,
              command: UInt8,
              payload: [UInt8],
              key: [UInt8],
              iv: [UInt8],
              id: [UInt8],
              mac: [UInt8]) throws
}

public final class DefaultAUXNetworkService: AUXNetworkService {
    private var count: UInt16 = UInt16(arc4random_uniform(0xffff))
    private let networkService: NetworkService
    
    public init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    public func send(to ipAddress: String,
                     port: Int,
                     command: UInt8,
                     payload: [UInt8],
                     key: [UInt8],
                     iv: [UInt8],
                     id: [UInt8],
                     mac: [UInt8]) throws {
        count = (count + 1) & 0xffff
        
        var packet = [UInt8].init(repeating: 0, count: 0x38)
        
        packet[0x00] = 0x5a
        packet[0x01] = 0xa5
        packet[0x02] = 0xaa
        packet[0x03] = 0x55
        packet[0x04] = 0x5a
        packet[0x05] = 0xa5
        packet[0x06] = 0xaa
        packet[0x07] = 0x55
        
        //0x4E2A
        packet[0x24] = 0x2a// #==> Type
        packet[0x25] = 0x4e// #==> Type
        packet[0x26] = command
        
        //        packet[0x28] = UInt8(count & 0xff)
        //        packet[0x29] = UInt8(count >> 8)
        
        packet[0x2a] = mac[0]
        packet[0x2b] = mac[1]
        packet[0x2c] = mac[2]
        packet[0x2d] = mac[3]
        packet[0x2e] = mac[4]
        packet[0x2f] = mac[5]
        packet[0x30] = id[0]
        packet[0x31] = id[1]
        packet[0x32] = id[2]
        packet[0x33] = id[3]
        
        //        let payloadChecksum = payload.reduce(UInt16(0xbeaf), { (UInt16($0) + UInt16($1)) & 0xffff})
        //        packet[0x34] = UInt8(payloadChecksum & 0xff)
        //        packet[0x35] = UInt8(payloadChecksum >> 8)
        //
        //        let encryptedPayload = try AES(key: key, blockMode: CBC(iv: iv), padding: .noPadding).encrypt(payload)
        //        packet.append(contentsOf: encryptedPayload)
        //
        //        let packetChecksum = packet.reduce(UInt16(0xbeaf), { (UInt16($0) + UInt16($1)) & 0xffff})
        //        packet[0x20] = UInt8(packetChecksum & 0xff)
        //        packet[0x21] = UInt8(packetChecksum >> 8)
        //        try networkService.send(bytes: packet, to: ipAddress, port: port)
        
        var buffer: ByteBuffer = .init(.init(packet))
        buffer.setInteger(count, at: 0x28, endianness: .little)//writeInteger(count, endianness: .little)
        
        buffer.setInteger(payload.reduce(UInt16(0xbeaf), { (UInt16($0) + UInt16($1)) & 0xffff}),
                          at: 0x34,
                          endianness: .little)
        
        let data = try AES(key: key, blockMode: CBC(iv: iv), padding: .noPadding).encrypt(payload)
        buffer.writeBytes(data)
        
        buffer.setInteger(buffer.readableBytesView.reduce(UInt16(0xbeaf), { (UInt16($0) + UInt16($1)) & 0xffff}),
                          at: 0x20,
                          endianness: .little)
        
        try networkService.send(bytes: buffer.readableBytesView, to: ipAddress, port: port)
    }
    
}


























//    func discover() throws {
//        guard let ipAdress = networkService.ipAddress else { return }
//        guard let port = networkService.port else { return }
//        var buffer: ByteBuffer = .init(.init([UInt8].init(repeating: 0, count: 0x30)))
//
//        let timezone = TimeZone.current.secondsFromGMT() / -3600
//        print(timezone)
//        if (timezone < 0) {
//            buffer.setInteger(UInt32(0xff + timezone - 1), at: 0x08, endianness: .little, as: UInt32.self)
//            buffer.setInteger(0xff, at: 0x09, endianness: .little, as: UInt32.self)
//            buffer.setInteger(0xff, at: 0x0a, endianness: .little, as: UInt32.self)
//            buffer.setInteger(0xff, at: 0x0b, endianness: .little, as: UInt32.self)
//        } else {
//            buffer.setInteger(UInt32(timezone), at: 0x08, endianness: .little, as: UInt32.self)
//            buffer.setInteger(0, at: 0x09, endianness: .little, as: UInt32.self)
//            buffer.setInteger(0, at: 0x0a, endianness: .little, as: UInt32.self)
//            buffer.setInteger(0, at: 0x0b, endianness: .little, as: UInt32.self)
//        }
//
//        let year = Calendar.current.component(.year, from: date)
//        buffer.setInteger(UInt16(year), at: 0x0c, endianness: .big, as: UInt16.self)
//
//        let seconds = Calendar.current.component(.second, from: date)
//        buffer.setInteger(UInt8(seconds), at: 0x0c, endianness: .big, as: UInt8.self)
//
//        let minute = Calendar.current.component(.minute, from: date)
//        buffer.setInteger(UInt8(minute), at: 0x0f, endianness: .big, as: UInt8.self)
//
//        let hour = Calendar.current.component(.hour, from: date)
//        buffer.setInteger(UInt8(hour), at: 0x10, endianness: .big, as: UInt8.self)
//
//        let weekday = Calendar.current.component(.weekday, from: date) - 1
//        buffer.setInteger(UInt8(weekday), at: 0x11, endianness: .big, as: UInt8.self)
//
//        let day = Calendar.current.component(.day, from: date)
//        buffer.setInteger(UInt8(day), at: 0x12, endianness: .big, as: UInt8.self)
//
//        let month = Calendar.current.component(.month, from: date)
//        buffer.setInteger(UInt8(month), at: 0x13, endianness: .big, as: UInt8.self)
//
//        let components = ipAdress.split(separator: ".").compactMap({ UInt8($0) })
//        buffer.setInteger(components[0], at: 0x18, endianness: .big, as: UInt8.self)
//        buffer.setInteger(components[1], at: 0x19, endianness: .big, as: UInt8.self)
//        buffer.setInteger(components[2], at: 0x1a, endianness: .big, as: UInt8.self)
//        buffer.setInteger(components[3], at: 0x1b, endianness: .big, as: UInt8.self)
//
//        buffer.setInteger(UInt16(port), at: 0x1c, endianness: .little, as: UInt16.self)
//        buffer.setInteger(UInt8(6), at: 0x26, endianness: .big, as: UInt8.self)
//
//        let checksum = buffer.readableBytesView.reduce(UInt16(0xbeaf), { UInt16($0) + UInt16($1) })
//        buffer.setInteger(checksum, at: 0x20, endianness: .little, as: UInt16.self)
//
//
//        try networkService.send(bytes: buffer.readableBytesView, to: "255.255.255.255", port: 80)
//
//    }
