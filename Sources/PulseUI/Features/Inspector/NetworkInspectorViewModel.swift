// The MIT License (MIT)
//
// Copyright (c) 2020–2022 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import CoreData
import PulseCore
import Combine

final class NetworkInspectorViewModel: ObservableObject {
    private(set) var title: String = ""

    let summaryViewModel: NetworkInspectorSummaryViewModel
    let responseViewModel: NetworkInspectorResponseViewModel
    let requestViewModel: NetworkInspectorRequestViewModel
#if !os(watchOS)
    let headersViewModel: NetworkInspectorHeadersTabViewModel
    let metricsViewModel: NetworkInspectorMetricsTabViewModel
#endif

    // TODO: Make private
    let request: LoggerNetworkRequestEntity
    let store: LoggerStore

    init(request: LoggerNetworkRequestEntity, store: LoggerStore) {
        self.request = request
        self.store = store

        if let url = request.url.flatMap(URL.init(string:)) {
            self.title = url.lastPathComponent
        }

        self.summaryViewModel = NetworkInspectorSummaryViewModel(request: request, store: store)
        self.responseViewModel = NetworkInspectorResponseViewModel(request: request, store: store)
        self.requestViewModel = NetworkInspectorRequestViewModel(request: request, store: store)
#if !os(watchOS)
        self.headersViewModel = NetworkInspectorHeadersTabViewModel(request: request)
        self.metricsViewModel = NetworkInspectorMetricsTabViewModel(request: request)
#endif
    }

    var pin: PinButtonViewModel? {
        request.message.map {
            PinButtonViewModel(store: store, message: $0)
        }
    }

    func prepareForSharing() -> String {
        ConsoleShareService(store: store).share(request, output: .plainText)
    }
}