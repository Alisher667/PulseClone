// The MIT License (MIT)
//
// Copyright (c) 2020–2022 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import CoreData
import PulseCore
import Combine

#if os(iOS)

struct NetworkInsightsRequestsList: View {
    @ObservedObject var viewModel: NetworkInsightsRequestsListViewModel

    public var body: some View {
        ConsoleTableView(
            header: { EmptyView() },
            viewModel: viewModel.table,
            detailsViewModel: viewModel.details
        )
    }
}

final class NetworkInsightsRequestsListViewModel: ObservableObject {
    let table: ConsoleTableViewModel
    let details: ConsoleDetailsRouterViewModel

    init(requests: [LoggerNetworkRequestEntity], store: LoggerStore) {
        self.table = ConsoleTableViewModel(store: store, searchCriteriaViewModel: nil)
        self.table.entities = requests
        self.details = ConsoleDetailsRouterViewModel(store: store)
    }
}

#endif