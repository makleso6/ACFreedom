////
////  SendPacketTests.swift
////  ACFreedomTests
////
////  Created by Maksim Kolesnik on 27.06.2020.
////
//
//import XCTest
//import Foundation
//import NIO
//import Cryptor
//import CryptoSwift
//
//class SendPacketTests: XCTestCase {
//    
//    lazy var handler: ChannelHandler = {
//        
//        return NIOChanelInboundHandler()
//    }()
//    
//    lazy var networkService: NetworkService? = {
//        
//        return try? NIONetworkService(handler: handler)
//    }()
//    
//    func testExample() throws {
//        /*
//        let value1 = 0b00000000
//        print(value1)
//
//        
//        
//        let value2 = 0b00001111
//        print(value2)
//
//        let value3 = 0x00
//        print(value3)
//        
//        let tmp = 16
//        let fix = 3
//        let value = 0b00000000 | (tmp << 3 ) | fix
//        print("value", value)
//
//        let key: [UInt8] = [0x09, 0x76, 0x28, 0x34, 0x3f, 0xe9, 0x9e, 0x23, 0x76, 0x5c, 0x15, 0x13, 0xac, 0xcf, 0x8b, 0x02]
//        let key: [UInt8] = [0x19, 0xf3, 0x6b, 0xa7, 0x35, 0xc9, 0x47, 0xfb, 0x11, 0x3f, 0x25, 0xf5, 0xc3, 0x59, 0xb1, 0x37]
//        let iv: [UInt8] =  [0x56, 0x2e, 0x17, 0x99, 0x6d, 0x09, 0x3d, 0x28, 0xdd, 0xb3, 0xba, 0x69, 0x5a, 0x2e, 0x6f, 0x58]
//
//        var buffer: ByteBuffer = .init(.init([UInt8].init(repeating: 0, count: 0x38)))
//        buffer.setInteger(0x5a, at: 0x00)
//        buffer.setInteger(0xa5, at: 0x02)
//        buffer.setInteger(0xaa, at: 0x03)
//        buffer.setInteger(0x55, at: 0x04)
//        buffer.setInteger(0xa5, at: 0x05)
//        buffer.setInteger(0xaa, at: 0x06)
//        buffer.setInteger(0x55, at: 0x07)
//        
//        /// Device type as a little-endian 16 bit integer
//        buffer.setInteger(0x2a, at: 0x24) // packet[0x24] = self.devtype & 0xff
//        buffer.setInteger(0x27, at: 0x25) // packet[0x25] = self.devtype >> 8
//        
//        /// Command code as a little-endian 16 bit integer
//        let code: UInt16 =  1
//        buffer.setInteger(code, at: 0x26, endianness: .little)
//        
//        /// Packet count as a little-endian 16 bit integer
//        let count: UInt16 =  1
//        buffer.setInteger(count, at: 0x28, endianness: .little)
//        
//        ///Local MAC address
//        let mac: [UInt8] = [0x34, 0xea, 0x34, 0x96, 0xe7, 0x05]
//        buffer.setInteger(mac[5], at: 0x2a)
//        buffer.setInteger(mac[4], at: 0x2b)
//        buffer.setInteger(mac[3], at: 0x2c)
//        buffer.setInteger(mac[2], at: 0x2d)
//        buffer.setInteger(mac[1], at: 0x2e)
//        buffer.setInteger(mac[0], at: 0x2f)
//        
//        let id: [UInt8] = [0x00, 0x00, 0x00, 0x00]
//        buffer.setInteger(id[3], at: 0x30)
//        buffer.setInteger(id[2], at: 0x31)
//        buffer.setInteger(id[1], at: 0x32)
//        buffer.setInteger(id[0], at: 0x33)
//        
//        var payload: ByteBuffer = .init(.init([UInt8].init(repeating: 0, count: 0x17)))
//        
//        let checksum = payload.readableBytesView.reduce(UInt16(0xbeaf), { (UInt16($0) + UInt16($1)) & 0xffff })
//        
//        buffer.setInteger(checksum, at: 0x34, endianness: .little)
//
//        
//        */
//        
////        let key: [UInt8] = [0x09, 0x76, 0x28, 0x34, 0x3f, 0xe9, 0x9e, 0x23, 0x76, 0x5c, 0x15, 0x13, 0xac, 0xcf, 0x8b, 0x02]
//        
//        print("2ba9ae5dcbdc9cb49f13c44a6b5b1c52ee4e694ef355ad97a833cde56d0510b6".separate(every: 2, with: ", 0x"))
//        
//        let key: [UInt8] = [0x19, 0xf3, 0x6b, 0xa7, 0x35, 0xc9, 0x47, 0xfb, 0x11, 0x3f, 0x25, 0xf5, 0xc3, 0x59, 0xb1, 0x37]
//        let iv: [UInt8] =  [0x56, 0x2e, 0x17, 0x99, 0x6d, 0x09, 0x3d, 0x28, 0xdd, 0xb3, 0xba, 0x69, 0x5a, 0x2e, 0x6f, 0x58]
//
////
////
////        let encrypted: [UInt8] = [0x2b, 0xa9, 0xae, 0x5d, 0xcb, 0xdc, 0x9c, 0xb4, 0x9f, 0x13, 0xc4, 0x4a, 0x6b, 0x5b, 0x1c, 0x52, 0xee, 0x4e, 0x69, 0x4e, 0xf3, 0x55, 0xad, 0x97, 0xa8, 0x33, 0xcd, 0xe5, 0x6d, 0x05, 0x10, 0xb6]
////        let encrypted: [UInt8] = [0x9e, 0x1f, 0xd6, 0xf5, 0xd5, 0x98, 0x2b, 0xd7, 0xc8, 0x07, 0x5d, 0x88, 0x3d, 0x95, 0x78, 0x83, 0xdd, 0x9f, 0x87, 0xc5, 0xae, 0xa2, 0x67, 0x5c, 0xb1, 0x91, 0x42, 0xb6, 0x40, 0x92, 0x2c, 0x13]
//        let encrypted: [UInt8] = "2ba9ae5dcbdc9cb49f13c44a6b5b1c52ee4e694ef355ad97a833cde56d0510b6".hexaBytes
//        print("enc", try AES(key: key, blockMode: CBC(iv: iv), padding: .iso78164).decrypt(encrypted))
//        print("enc", try AES(key: key, blockMode: CBC(iv: iv), padding: .noPadding).decrypt(encrypted))
//        print("enc", try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs5).decrypt(encrypted))
//        print("enc", try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7).decrypt(encrypted))
//        print("enc", try AES(key: key, blockMode: CBC(iv: iv), padding: .zeroPadding).decrypt(encrypted))
//
//        
//    }
//    
//    func aes128(data: [UInt8], key: [UInt8], iv: [UInt8]) throws -> [UInt8] {
//        //        let data = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions(rawValue: 0))
//        let dec = try AES(key: key, blockMode: CBC.init(iv: iv)).decrypt(data)//(key: key, iv: iv, blockMode:.CBC).decrypt(data!.arrayOfBytes(), padding: PKCS7())
//        
//        let decData = NSData(bytes: dec, length: Int(dec.count))
//        //        let result = NSString(data: decData, encoding: NSUTF8StringEncoding)
//        return dec
//    }
//    
//    private func aes(_ bytes: [UInt8], key: [UInt8], iv: [UInt8], operation: StreamCryptor.Operation) throws -> [UInt8] {
//        let cryptor = try StreamCryptor.init(operation: operation, algorithm: .aes128, options: [.pkcs7Padding], key: key, iv: iv)
//        var result: [UInt8] = .init(repeating: 0, count: bytes.count)
//        let updateResult = cryptor.update(byteArrayIn: bytes, byteArrayOut: &result)
//        result = Array(result.prefix(updateResult.0))
//        var final = result
//        let finalResult = cryptor.final(byteArrayOut: &final)
//        final = Array(final.prefix(finalResult.0))
//        return result + final
//    }
//    
//}
//
//extension String {
//
//    func separate(every: Int, with separator: String) -> String {
//        
//        return String(stride(from: 0, to: count, by: every)
//            .map {
//                Array(Array(self)[$0..<min($0 + every, Array(self).count)])
//        }
//        .joined(separator: separator))
//    }
//    
//}
//
//extension StringProtocol {
//    var hexaData: Data { .init(hexa) }
//    var hexaBytes: [UInt8] { .init(hexa) }
//    private var hexa: UnfoldSequence<UInt8, Index> {
//        sequence(state: startIndex) { startIndex in
//            guard startIndex < self.endIndex else { return nil }
//            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
//            defer { startIndex = endIndex }
//            return UInt8(self[startIndex..<endIndex], radix: 16)
//        }
//    }
//}
///*
// 5aa5aa555aa5aa550000000000000000000000000000000000000000000000002bdc00002a4e6a001cb405e79634ea3401000000c3c30000d8dbaf7f6169b89423ffb28fe8ae6ca2b2f04ae99bba374ed177dd6410f788ae
// 5aa5aa555aa5aa55000000000000000000000000000000000000000000000000a2d700002a4e6a0062d905e79634ea3401000000c3c30000df529f17713f3c270d2be2775d077dd03a17b49ad7a9632b7264dcb3cd96ae20
// 
// */
