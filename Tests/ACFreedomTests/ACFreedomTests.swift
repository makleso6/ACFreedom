import XCTest
//@testable import ACFreedom
import Foundation
import NIO

final class ACFreedomTests: XCTestCase {
    
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
        XCTAssertEqual(ACFreedom().text, "Hello, World!")
        let date = Date(timeIntervalSince1970: 1592331610)
        let ipAdress = "127.0.0.1"
        let port = 80
        
        var buffer: ByteBuffer = .init(.init([UInt8].init(repeating: 0, count: 0x30)))
        //
        let timezone = 0//TimeZone.current.secondsFromGMT() / -3600
        //        //        buffer.setInteger(UInt32(timezone), at: 0, endianness: .little, as: UInt32.self)
        //
        if (timezone < 0) {
            buffer.setInteger(UInt32(0xff + timezone - 1), at: 0x08, endianness: .little, as: UInt32.self)
            buffer.setInteger(0xff, at: 0x09, endianness: .little, as: UInt32.self)
            buffer.setInteger(0xff, at: 0x0a, endianness: .little, as: UInt32.self)
            buffer.setInteger(0xff, at: 0x0b, endianness: .little, as: UInt32.self)
        } else {
            buffer.setInteger(UInt32(timezone), at: 0x08, endianness: .little, as: UInt32.self)
            buffer.setInteger(0, at: 0x09, endianness: .little, as: UInt32.self)
            buffer.setInteger(0, at: 0x0a, endianness: .little, as: UInt32.self)
            buffer.setInteger(0, at: 0x0b, endianness: .little, as: UInt32.self)
        }
        //
        let year = Calendar.current.component(.year, from: date)
        buffer.setInteger(UInt16(year), at: 0x0c, endianness: .little, as: UInt16.self)
        //        buffer.setInteger(UInt32(year >> 8), at: 0x0c, endianness: .little, as: UInt32.self)
        //
        let seconds = Calendar.current.component(.second, from: date)
        buffer.setInteger(UInt8(seconds), at: 0x0e, endianness: .little, as: UInt8.self)
        
        let minute = Calendar.current.component(.minute, from: date)
        buffer.setInteger(UInt8(minute), at: 0x0f, endianness: .little, as: UInt8.self)
        //
        let hour = Calendar.current.component(.hour, from: date)
        buffer.setInteger(UInt8(hour), at: 0x10, endianness: .little, as: UInt8.self)
        //
        //        buffer.setInteger(UInt8(year % 100), at: 0x10, endianness: .little, as: UInt8.self)
        //
        //        //        let second = Calendar.current.component(.second, from: date)
        //        //        buffer.setInteger(UInt8(second), at: 6, endianness: .little, as: UInt8.self)
        //
        let weekday = Calendar.current.component(.weekday, from: date) - 1
        buffer.setInteger(UInt8(weekday), at: 0x11, endianness: .little, as: UInt8.self)
        //        print(weekday)
        let day = Calendar.current.component(.day, from: date)
        buffer.setInteger(UInt8(day), at: 0x12, endianness: .little, as: UInt8.self)
        //        print(day)
        let month = Calendar.current.component(.month, from: date) - 1
        buffer.setInteger(UInt8(month), at: 0x13, endianness: .little, as: UInt8.self)
        //
        let components = ipAdress.split(separator: ".").compactMap({ UInt8($0) })
        buffer.setInteger(components[0], at: 0x18, endianness: .little, as: UInt8.self)
        buffer.setInteger(components[1], at: 0x19, endianness: .little, as: UInt8.self)
        buffer.setInteger(components[2], at: 0x1a, endianness: .little, as: UInt8.self)
        buffer.setInteger(components[3], at: 0x1b, endianness: .little, as: UInt8.self)
        //
        buffer.setInteger(UInt16(port), at: 0x1c, endianness: .little, as: UInt16.self)
        buffer.setInteger(UInt16(6), at: 0x26, endianness: .little, as: UInt16.self)
        //        buffer.setInteger(UInt8(port >> 8), at: 0x1d, endianness: .little, as: UInt8.self)
        //
        //        //        buffer.capacity
        let checksum = buffer.readableBytesView.reduce(UInt16(0xbeaf), { UInt16($0) + UInt16($1) })
        //        checksum = checksum & 0xffff
                buffer.setInteger(checksum, at: 0x1a, endianness: .little, as: UInt16.self)
        ////        buffer.setInteger(UInt8(checksum >> 8), at: 0x1b, endianness: .little, as: UInt8.self)
        //        print(buffer)
        //        print(buffer.readableBytesView)
                print("buffer.readableBytesView.map({ $0 })")
                print(buffer.readableBytesView.map({ $0 }))
    }
    
    static var allTests = [
        ("testExample", testExample),
    ]
}
