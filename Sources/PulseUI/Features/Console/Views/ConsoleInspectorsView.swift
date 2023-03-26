// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

#if os(macOS)

import SwiftUI

struct ConsoleInspectorsView: View {
    let viewModel: ConsoleViewModel
    @State private var selectedTab: ConsoleInspector = .filters

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            selectedTabView
        }
    }

    private var inspectors: [ConsoleInspector] {
        var inspectors = ConsoleInspector.allCases
        if isRunningStandaloneApp {
            inspectors.removeAll(where: { $0 == .settings })
        }
        return inspectors
    }

    private var toolbar: some View {
        HStack {
            Spacer()
            ForEach(inspectors) { item in
                TabBarItem(image: Image(systemName: item.systemImage), isSelected: item == selectedTab) {
                    selectedTab = item
                }
            }
            Spacer()
        }.padding(EdgeInsets(top: 3, leading: 10, bottom: 4, trailing: 8))
    }

    @ViewBuilder
    private var selectedTabView: some View {
        switch selectedTab {
        case .filters:
            ConsoleSearchCriteriaView(viewModel: viewModel.searchCriteriaViewModel)
        case .storeInfo:
            VStack {
                StoreDetailsView(source: .store(viewModel.store))
                Spacer()
            }
        case .insights:
            VStack {
                InsightsView(viewModel: viewModel.insightsViewModel)
                Spacer()
            }
        case .settings:
            VStack {
                SettingsView(store: viewModel.store)
                Spacer()
            }
        }
    }
}

private enum ConsoleInspector: Identifiable, CaseIterable {
    case filters
    case insights
    case storeInfo
    case settings

    var id: ConsoleInspector { self }

    var systemImage: String {
        switch self {
        case .filters:
            return "line.3.horizontal.decrease.circle"
        case .storeInfo:
            return "info.circle"
        case .settings:
            return "gearshape"
        case .insights:
            return "chart.pie"
        }
    }
}

private struct TabBarItem: View {
    let image: Image
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            image
                .foregroundColor(isSelected ? .white : .secondary)
                .padding(2)
                .padding(.horizontal, 2)
                .onHover { isHovering = $0 }
                .background(isSelected ? Color.blue.opacity(0.8) : (isHovering ? Color.blue.opacity(0.25) : nil))
                .cornerRadius(4)
        }.buttonStyle(.plain)
    }
}

#endif
