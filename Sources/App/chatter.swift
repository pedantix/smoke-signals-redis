import Redis
import WebSocket
import Vapor

func chatterHandler(_ ws: WebSocket, req: Request) throws {
    let channelName: String = try req.parameter()
    let logger = try req.make(Logger.self)
    let clientConfig = try req.make(RedisClientConfig.self)
    var subscriptionClient: RedisClient? = nil

    // Subscribe to channel
    guard let loop = MultiThreadedEventLoopGroup.currentEventLoop else { return }
    _ = RedisDatabase(config: clientConfig)
        .makeConnection(on: loop)
        .map(to: Void.self, { conn in
            _ = try conn.subscribe(Set([channelName]),subscriptionHandler: { redisData in
                guard let message = redisData.data.string else { return }
                ws.send(message)
            })
            subscriptionClient = conn
        })
    
    ws.onText({ text in
        _ = req.connect(to: .redis).map(to: Void.self, { conn in
            _ = conn.publish(RedisData(bulk: text), to: channelName)
        })
    })

    ws.onClose {
        subscriptionClient?.close()
        logger.info("Socket disconnected \(channelName)")
    }
}
