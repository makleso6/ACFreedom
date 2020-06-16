import XCTest
//@testable import ACFreedom
import Foundation
import NIO

final class ACFreedomTests: XCTestCase {
    
    lazy var handler: ChannelHandler = {
        
        return NIOChanelInboundHandler()
    }()
    
    lazy var networkService: NetworkService? = {
        
        return try? NIONetworkService(handler: handler)
    }()
    //        func testExample() {
    //            let date = Date(timeIntervalSince1970: 1592331610)
    //            let ipAdress = "127.0.0.1"
    //            let port = 80
    //            let timezone = 0//TimeZone.current.secondsFromGMT() / -3600
    //            var packet: [UInt8] = []
    //        }
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(ACFreedom().text, "Hello, World!")
//        let date = Date(timeIntervalSince1970: 1592331610)
//        let ipAdress = "127.0.0.1"
//        let port = 80
        
        guard let ipAdress = networkService?.ipAddress else { return }
        guard let port = networkService?.port else { return }
        let date = Date()

        var buffer = [UInt8].init(repeating: 0, count: 0x30)
        
        let timezone = TimeZone.current.secondsFromGMT() / -3600
        print(timezone)
        if (timezone < 0) {
            buffer[0x08] = UInt8(0xff + timezone - 1)
            buffer[0x09] = 0xff
            buffer[0x0a] = 0xff
            buffer[0x0b] = 0xff
        } else {
            buffer[0x08] = UInt8(timezone)
            buffer[0x09] = 0
            buffer[0x0a] = 0
            buffer[0x0b] = 0
        }

        let year = Calendar.current.component(.year, from: date)
        buffer[0x0c] = UInt8(year & 0xff)
        buffer[0x0d] = UInt8(year >> 8)
        let minute = Calendar.current.component(.minute, from: date)
        buffer[0x0e] = UInt8(minute)

        let hour = Calendar.current.component(.hour, from: date)
        buffer[0x0f] = UInt8(hour)

        guard let subyear = Int(String(year).suffix(2)) else { return }
        buffer[0x10] = UInt8(hour)

//        buffer.setInteger(UInt8(hour), at: 0x10, endianness: .big, as: UInt8.self)
//
        let weekday = Calendar.current.component(.weekday, from: date) - 1
        buffer[0x11] = UInt8(weekday)

//        buffer.setInteger(UInt8(weekday), at: 0x11, endianness: .big, as: UInt8.self)
//
        let day = Calendar.current.component(.day, from: date)
        buffer[0x12] = UInt8(day)

//        buffer.setInteger(UInt8(day), at: 0x12, endianness: .big, as: UInt8.self)
//
        let month = Calendar.current.component(.month, from: date)
        buffer[0x13] = UInt8(month)

//        buffer.setInteger(UInt8(month), at: 0x13, endianness: .big, as: UInt8.self)
//
        let components = ipAdress.split(separator: ".").compactMap({ UInt8($0) })
        buffer[0x18] = components[0]
        buffer[0x19] = components[1]
        buffer[0x1a] = components[2]
        buffer[0x1b] = components[3]

        buffer[0x1c] = UInt8(port & 0xff)
        buffer[0x1d] = UInt8(port >> 8)

        buffer[0x26] = 6

//        buffer.setInteger(components[0], at: 0x18, endianness: .big, as: UInt8.self)
//        buffer.setInteger(components[1], at: 0x19, endianness: .big, as: UInt8.self)
//        buffer.setInteger(components[2], at: 0x1a, endianness: .big, as: UInt8.self)
//        buffer.setInteger(components[3], at: 0x1b, endianness: .big, as: UInt8.self)
//        //
//        buffer.setInteger(UInt16(port), at: 0x1c, endianness: .little, as: UInt16.self)
//        buffer.setInteger(UInt16(6), at: 0x26, endianness: .big, as: UInt16.self)
//        //        buffer.setInteger(UInt8(port >> 8), at: 0x1d, endianness: .little, as: UInt8.self)
//        //
//        //        //        buffer.capacity
        let checksum = buffer.reduce(UInt16(0xbeaf), { UInt16($0) + UInt16($1) })
        buffer[0x20] = UInt8(checksum & 0xff)
        buffer[0x21] = UInt8(checksum >> 8)

//        //        checksum = checksum & 0xffff
//        buffer.setInteger(checksum, at: 0x20, endianness: .little, as: UInt16.self)
//        ////        buffer.setInteger(UInt8(checksum >> 8), at: 0x1b, endianness: .little, as: UInt8.self)
//        //        print(buffer)
//        //        print(buffer.readableBytesView)
//        print("buffer.readableBytesView.map({ $0 })")
//        print(buffer.readableBytesView.map({ $0 }))
        let expectation = XCTestExpectation(description: "Download apple.com home page")

        try? networkService?.send(bytes: buffer, to: "255.255.255.255", port: 80)

        wait(for: [expectation], timeout: 10.0)
    }
    
    static var allTests = [
        ("testExample", testExample),
    ]
}
