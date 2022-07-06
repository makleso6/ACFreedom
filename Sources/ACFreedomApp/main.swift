import ACFreedom
import Foundation


let controller = try DeviceController(
    networkService: DefaultAUXNetworkService(
        networkService: NIONetworkService(handler: NIOChanelInboundHandler())
    ),
    mac: [0xa0,0x43,0xb0,0xf0,0xc7,0xe3],
    ip: "192.168.1.44"
)

try controller.auth()

RunLoop.main.run()
