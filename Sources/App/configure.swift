import Redis
import Vapor

/// Called before your application initializes.
///
/// https://docs.vapor.codes/3.0/getting-started/structure/#configureswift
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    /// Register providers first
    try services.register(RedisProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)



    /// Register the configured SQLite database to the database config.
    var databases = DatabaseConfig()
    var redisConfig: RedisClientConfig = RedisClientConfig()
    redisConfig.hostname = ProcessInfo.processInfo.environment["REDIS_HOSTNAME"] ?? redisConfig.hostname
    redisConfig.port = ProcessInfo.processInfo.environment["REDIS_PORT"]?.intValue ?? redisConfig.port

    let redisDatabse = RedisDatabase(config: redisConfig)
    databases.add(database: redisDatabse, as: .redis)
    services.register(databases)
    services.register(redisConfig)

    configureWebsockets(&services)
}

func configureWebsockets(_ services: inout Services) {
    let websockets = EngineWebSocketServer.default()
    websockets.get("socket", String.parameter, use: chatterHandler)
    services.register(websockets, as: WebSocketServer.self)
}
