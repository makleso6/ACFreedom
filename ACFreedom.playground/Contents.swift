import Foundation
import CryptoSwift

extension StringProtocol {
    var hexaData: Data { .init(hexa) }
    var hexaBytes: [UInt8] { .init(hexa) }
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}

let key: [UInt8] = [0x19, 0xf3, 0x6b, 0xa7, 0x35, 0xc9, 0x47, 0xfb, 0x11, 0x3f, 0x25, 0xf5, 0xc3, 0x59, 0xb1, 0x37]
let iv: [UInt8] =  [0x56, 0x2e, 0x17, 0x99, 0x6d, 0x09, 0x3d, 0x28, 0xdd, 0xb3, 0xba, 0x69, 0x5a, 0x2e, 0x6f, 0x58]

func decrypt(_ data: String) throws -> [UInt8]  {
    let data = try AES(key: key, blockMode: CBC(iv: iv), padding: .noPadding)
        .decrypt(data.hexaBytes)
    return data
}



func printFan(_ data: String) throws {
    let data = try decrypt(data)
    let fan = data[15] >> 5
    print("Fan", fan)
}

func printSwingV(_ data: String) throws {
    let data = try decrypt(data)
    let fan = data[13] >> 7 // 7(0,1) or 5(0,7)
    print("SwingV", fan)
}

func printSwingH(_ data: String) throws {
    let data = try decrypt(data)
    let fan = data[12] & 0b00000001 // 0b00000001(0,1) or 0b00000111 (0,7)
    print("SwingH", fan)
}

func printTurbo(_ data: String) throws {
    let data = try decrypt(data)
    //    print("data", data[16])
    let mute = data[16] >> 7
    //    let turbo = data[16] >> 6
    print("mute", mute)
    //    print("turbo", turbo)
}

func printTemp(_ data: String) throws {
    let data = try decrypt(data)
    print(data)
    print(data[12])
    let temp = data[12] >> 3
    print("temp", temp + 8)
}

//e0cdc7eecdb5d4ba1cccf5bda685f32f473a69010611b4c5c0a1b4ff218f0742 16c Von
//3672e62cc49bc32e60636b207f4ee5effb3ddc28cd1e70329dc68799a950e59e 16c Von
//print(try decrypt("e0cdc7eecdb5d4ba1cccf5bda685f32f473a69010611b4c5c0a1b4ff218f0742"))
//print(try decrypt("3672e62cc49bc32e60636b207f4ee5effb3ddc28cd1e70329dc68799a950e59e"))
//print(try decrypt("a2436a9b2f55a5b3bcb66be4ba57a29b293e414c4faf0796e864e04792834bce"))
//print(try decrypt("233a4d44ccd58261c344a84bc15ef12153cccb72e07d44bbf8891153fb577b10"))
//print(try decrypt("246c21945646e0bfcd02270b50d70777")) //16c von
////print(try decrypt("aeaac104468cf91b485f38c67f7bf57f")) //16c von
//print("0C00BB0006800000020011012B7E0000".hexaBytes)
//print("0C00BB0006800000020021011B7E0000".hexaBytes)
//print(try decrypt("7e06f3eca36c273b9709fae0621b6b22")) //16c von
//print(try decrypt("7e06f3eca36c273b9709fae0621b6b22")) //16c von
//
//
//
//
//
//
//print(try decrypt("e0cdc7eecdb5d4ba1cccf5bda685f32f473a69010611b4c5c0a1b4ff218f0742")) //16c von
//print(try decrypt("3672e62cc49bc32e60636b207f4ee5effb3ddc28cd1e70329dc68799a950e59e")) //16c voff
//print(try decrypt("f34756020a5bd120480b3be0eef8267ff89bc8e47311ca331dc37c88cb43bc57")) //16c von hon
//print(try decrypt("94f3ebcc53be0cbeea4165bd551706c7fbfdc4cf7b0cd79804bb673ce6646201")) //16c von hoff
//print(try decrypt("9f6e4bedc1399307522ec1c3145557345544ed11944b13d5d4110e0d4a48bdd4")) //16c voff hon
//print(try decrypt("81cc02a4e6790db9316c0217b37e74b87b1874285f540d5ae48c5545ee5b681b")) //16c voff hoff
//let value = 0b00000000 | 8 << 3 | 0
//print(value)
//print("")
//
//print(32 >> 5)
print(0 >> 5)
print(224 >> 5)


//
//try printTemp("2ba9ae5dcbdc9cb49f13c44a6b5b1c52ee4e694ef355ad97a833cde56d0510b6") //17c
//try printTemp("5ed2a0a6cda2b837b01ed7c93e8e67148ea8c655e7ee98d615253904086f4370") //19c
//try printTemp("bdbfcdbb01cd1672a4abe0b9625b7d650689462597f3241c710bba4b66e47f06") //24c
//try printTemp("45a579be1ea80a909ad16729e510bf8fa7225dc977b7c34c00146799cb606eb0") //19.5c
//print("")
//
//
////try printFan("5d4da92074069e808df33d14dacc79fcb875f6121a2cd23ccbbb9128b3252ace") // l
////try printFan("963832cfe45fd142a865744923c72b83585e534143aa3c03a51a82ec38d4ac58") // m
////try printFan("0fcdf27e1553f152029e0f4ce1e3b8be43eed93c643fbdae0741236c0aadec2e") // h
////try printFan("ca49ad42e645c2f177c4ae3a606c09743789246d1a6ca06aa6b3aa2173fdf9e8") // a
////
////print("")
////
//try printSwingH("4bb7f72083cc1d34365413775befb265df073863a7f413c1e57c71d809d5e3b2") //on
//try printSwingH("9a8bff2a95b532bbb9266aa064b7ec64cfb78d849f7924e0a6917e35ea8021a1") //off
//print("")
//
//try printSwingV("09e785e8e21e986bb6cf14d31d85ef27ff83cd41ee74dfb2b71d8250241eb854") //on
//try printSwingV("108e2ae705f42a56d2534a620a2c2b39bc0dabf8855368a7d4573329b0d4980a") // off
//print("")
//
//try printTurbo("de9fe71b5da232fa862ac73f3ae765e3ceabb594da778215b5a6d615786c0760")
//try printTurbo("2a6fa9ce7ad23b85d5f115ec9901fe8e844f2432c21963ab62fc1805c1af3196")
//print("")
//
////print(try decrypt("de9fe71b5da232fa862ac73f3ae765e3ceabb594da778215b5a6d615786c0760")) //quite
////print(try decrypt("5d4da92074069e808df33d14dacc79fc3b42f0d96aa754664b3b1a288e4d2a21")) // q
////
////print(try decrypt("2a6fa9ce7ad23b85d5f115ec9901fe8e844f2432c21963ab62fc1805c1af3196")) // super
////
////print(try decrypt("0fcdf27e1553f152029e0f4ce1e3b8be2cea1c17445195aa1b2dbfb2e187c5dc")) // t
//
//print(try decrypt("944325db95a5c3e704880508fc6050dc4dbbbc7e9e3e6cb784591656dc6709bb")) // quite
//try printTurbo("944325db95a5c3e704880508fc6050dc4dbbbc7e9e3e6cb784591656dc6709bb")
//try printFan("944325db95a5c3e704880508fc6050dc4dbbbc7e9e3e6cb784591656dc6709bb") // low
//try printTemp("944325db95a5c3e704880508fc6050dc4dbbbc7e9e3e6cb784591656dc6709bb") // low
//
//print(try decrypt("6c46ccfbd3839cec59bc832d82cff942877f507202664cd2ff17c5c19751b7a0")) // quite
//try printTurbo("6c46ccfbd3839cec59bc832d82cff942877f507202664cd2ff17c5c19751b7a0")
//try printFan("6c46ccfbd3839cec59bc832d82cff942877f507202664cd2ff17c5c19751b7a0") // low
//try printTemp("6c46ccfbd3839cec59bc832d82cff942877f507202664cd2ff17c5c19751b7a0") // low
//
//print(try decrypt("97bb5713dd0c6dcfc38eec34bded9c7ba8b48cb0a2311dbb7a144074a53a2f60")) // quite
//try printTurbo("97bb5713dd0c6dcfc38eec34bded9c7ba8b48cb0a2311dbb7a144074a53a2f60")
//try printFan("97bb5713dd0c6dcfc38eec34bded9c7ba8b48cb0a2311dbb7a144074a53a2f60") // high
//try printTemp("97bb5713dd0c6dcfc38eec34bded9c7ba8b48cb0a2311dbb7a144074a53a2f60") // low
////
////
////
////print("")
////
//print(try decrypt("6f4cad4d6c668c4e15c7311cbb9c9964511910c0a1e522ee486550f00eb4ec4f")) // turbo
//try printTurbo("6f4cad4d6c668c4e15c7311cbb9c9964511910c0a1e522ee486550f00eb4ec4f")
//try printFan("6f4cad4d6c668c4e15c7311cbb9c9964511910c0a1e522ee486550f00eb4ec4f") // low
//try printTemp("6f4cad4d6c668c4e15c7311cbb9c9964511910c0a1e522ee486550f00eb4ec4f") // low
//
//print(try decrypt("036facb57c557e27d1a0da035f1110a0fb62dcd0f1f5c97ac90ac48ed41d472f")) // turbo
//try printTurbo("036facb57c557e27d1a0da035f1110a0fb62dcd0f1f5c97ac90ac48ed41d472f")
//try printFan("036facb57c557e27d1a0da035f1110a0fb62dcd0f1f5c97ac90ac48ed41d472f") // high
//try printTemp("036facb57c557e27d1a0da035f1110a0fb62dcd0f1f5c97ac90ac48ed41d472f") // low
////
////
//let turbo = 0
//let mute = 0
//let val = 0b00000000 | turbo << 6 | mute << 7//        payload[14] = 0b00000000 | this.status['turbo << 6 | this.status['mute << 7
//
//print(val)
////
////
//
//
//
//let data = try decrypt("6376cbb09df5d7fbfa49194c5e96d1b53c9c42ec62861a8eb76aacd756128a0a")
//print(data) // turbo
//print(data[22]) // turbo
//let value = 0b00000000 | 1 << 4 | 0 << 3
//print(value)
//
//
//
//let int: UInt8 = Character(" ").asciiValue ?? 0
//print(int)
//
//
//
//[1,2,3,4,5,6,7,8,9,11,22,33,44,55,66,77,88,99,111,222,333,444,555,666,777,888,999][0...4]
//
//
////var request: [UInt8] = .init(repeating: 0, count: 32)
////var payload: [UInt8] = .init(repeating: 2, count: 23)
////request[0] = 25
////request.replaceSubrange(Range(uncheckedBounds: (2, 25)), with: payload)
////print(request)
//
//
////func checksum(data: [UInt8]) -> Int {
////
////    var mutableData = data
////    let len = mutableData.count
////    if len % 2 == 1 {
////        mutableData.append(0)
////    }
////    var sum = 0
////    var i = 0
////
////    while i <= len {
////        sum += (Int(mutableData[i]) << 8) + Int(mutableData[i + 1])
////        i += 2
////    }
////    sum = (sum >> 16) + (sum & 0xFFFF)
////    sum = ~sum & 0xFFFF
////
////    return sum
////}
////
////var payload: [UInt8] = .init(repeating: 0, count: 23)//Buffer.alloc(23, 0);
////payload[0] = 0xbb
////payload[1] = 0x00
////payload[2] = 0x06 //# Send command, seems like 07 is response
////payload[3] = 0x80
////payload[4] = 0x00
////payload[5] = 0x00
////payload[6] = 0x0f //# Set status .. #02 -> get info?
////payload[7] = 0x00
////payload[8] = 0x01
////payload[9] = 0x01
////
////print(checksum(data: payload))
////
////print("index",(187 << 8))

//print(0b00000111)
let response_payload: [UInt8] = [187, 0, 7, 0, 0, 0, 15, 0, 1, 17, 71, 32, 9, 96, 30, 32, 0, 0, 0, 0, 16, 0, 0, 175, 77, 102, 140, 22, 30, 49]
                              //[187, 0, 7, 0, 0, 0, 15, 0, 1, 17, 71, 32, 2, 32, 94, 32, 0, 0, 32, 0, 16, 0, 0, 86, 141, 102, 140, 22, 30, 49]
                              //[187, 0, 7, 0, 0, 0, 15, 0, 1, 17, 71, 32, 2, 32, 30, 32, 0, 0, 0, 0, 16, 0, 0, 182, 141, 0, 0, 0, 0, 0]
                              //[187, 0, 7, 0, 0, 0, 15, 0, 1, 17, 71, 32, 2, 32, 30, 32, 0, 0, 0, 0, 16, 0, 0, 182, 141, 0, 0, 0, 0, 0]
                              //[187, 0, 7, 0, 0, 0, 15, 0, 1, 17, 71, 32, 2, 32, 30, 32, 0, 0, 0, 0, 16, 0, 0, 182, 141, 45, 254, 175, 167, 105]
                              //[187, 0, 7, 0, 0, 0, 15, 0, 1, 17, 71, 32, 2, 32, 30, 32, 0, 0, 0, 0, 16, 0, 0, 182, 141, 0, 0, 0, 0, 0]



                              //[187, 0, 7, 0, 0, 0, 15, 0, 1, 17, 71, 32, 18, 96, 30, 32, 0, 0, 0, 0, 16, 0, 0, 166, 77, 102, 140, 22, 30, 49]
                              //[187, 0, 7, 0, 0, 0, 15, 0, 1, 17, 71, 32, 19, 96, 30, 32, 0, 0, 0, 0, 16, 0, 0, 165, 77, 0, 0, 0, 0, 0]
                              //[187, 0, 7, 0, 0, 0, 15, 0, 1, 17, 71, 32, 20, 96, 30, 32, 0, 0, 0, 0, 16, 0, 0, 164, 77, 102, 140, 22, 30, 49]
                              //[187, 0, 7, 0, 0, 0, 15, 0, 1, 17, 71, 32, 21, 96, 30, 32, 0, 0, 0, 0, 16, 0, 0, 163, 77, 102, 140, 22, 30, 49]
                              //[187, 0, 7, 0, 0, 0, 15, 0, 1, 17, 71, 32, 21, 96, 30, 32, 0, 0, 0, 0, 16, 0, 0, 163, 77, 102, 140, 22, 30, 49]



let temp = 8 + (response_payload[10]>>3) //+ (0.5 * float(response_payload[12]>>7))
let power = response_payload[18] >> 5 & 0b00000001
let fixation_v = response_payload[10] & 0b00000111
let mode = response_payload[15] >> 5 & 0b00001111
let sleep = response_payload[15] >> 2 & 0b00000001
let display = response_payload[20] >> 4 & 0b00000001
let mildew = response_payload[20] >> 3 & 0b00000001
let health = response_payload[18] >> 1 & 0b00000001
let fixation_h = response_payload[10]  & 0b00000111
let fanspeed  = response_payload[13] >> 5 & 0b00000111
let ifeel = response_payload[15] >> 3 & 0b00000001
let mute = response_payload[14] >> 7 & 0b00000001
let turbo = response_payload[14] >> 6 & 0b00000001
let clean = response_payload[18] >> 2 & 0b00000001
let ambient_temp = response_payload[15] & 0b00011111
 
