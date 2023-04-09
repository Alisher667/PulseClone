// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import Foundation
import Network
import Combine

extension RemoteLogger {
    /// - warning: This method is not designed to be used outside of the package.
    public static func _store(for url: URL) throws -> LoggerStore {
        var configuration = LoggerStore.Configuration()
        configuration.saveInterval = .milliseconds(120)
        configuration.isRemote = true
        return try LoggerStore(storeURL: url, options: [.create], configuration: configuration)
    }

    /// - warning: This method is not designed to be used outside of the package.
    public static func _saveSession(_ session: LoggerStore.Session, info: LoggerStore.Info.AppInfo, store: LoggerStore) {
        store.saveSession(session, info: info)
    }

    /// - warning: This method is not designed to be used outside of the package.
    public static func _process(_ event: LoggerStore.Event, store: LoggerStore) {
        store.handleExternalEvent(event)
    }
}
