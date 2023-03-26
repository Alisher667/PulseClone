// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import CoreData
import Pulse
import Combine
import SwiftUI

struct ConsoleListContentView: View {
    @ObservedObject var viewModel: ConsoleListViewModel

#if os(iOS)

    var body: some View {
        if #available(iOS 15, tvOS 15, *) {
            if !viewModel.pins.isEmpty, !viewModel.isShowingFocusedEntities {
                pinsView
            }
        }
        if #available(iOS 15, *), let sections = viewModel.sections, !sections.isEmpty {
            makeGroupedView(sections)
        } else {
            plainView
        }
    }

    @available(iOS 15.0, *)
    private func makeGroupedView(_ sections: [NSFetchedResultsSectionInfo]) -> some View {
        ForEach(sections, id: \.name) { section in
            let objects = (section.objects as? [NSManagedObject]) ?? []
            let prefix = objects.prefix(3)
            let sectionName = viewModel.name(for: section)
            PlainListExpandableSectionHeader(title: sectionName, count: section.numberOfObjects, destination: { EmptyView() }, isSeeAllHidden: true)
            ForEach(prefix, id: \.objectID) { entity in
                ConsoleEntityCell(entity: entity)
            }
            if prefix.count < objects.count {
                NavigationLink(destination: makeDestination(for: sectionName, objects: objects)) {
                    PlainListSeeAllView(count: objects.count)
                }
            }
        }
    }

    private func makeDestination(for title: String, objects: [NSManagedObject]) -> some View {
        LazyConsoleView(title: title, entities: objects, source: viewModel)
    }

    @available(iOS 15, tvOS 15, *)
    @ViewBuilder
    private var pinsView: some View {
        let prefix = Array(viewModel.pins.prefix(3))
        PlainListExpandableSectionHeader(title: "Pins", count: viewModel.pins.count, destination: {
            ConsoleStaticList(entities: viewModel.pins)
                .inlineNavigationTitle("Pins")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: viewModel.buttonRemovePinsTapped) {
                            Image(systemName: "trash")
                        }
                    }
                }
        }, isSeeAllHidden: prefix.count == viewModel.pins.count)
        ForEach(prefix.map(PinCellViewModel.init)) { viewModel in
            ConsoleEntityCell(entity: viewModel.object)
        }
        Button(action: viewModel.buttonRemovePinsTapped) {
            Text("Remove Pins")
                .font(.subheadline)
                .foregroundColor(Color.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.separator.opacity(0.2))
        .listRowSeparator(.hidden)
        .listRowSeparator(.hidden, edges: .bottom)

        if !viewModel.visibleEntities.isEmpty {
            PlainListGroupSeparator()
        }
    }
#else
    var body: some View {
        plainView
    }
#endif

    @ViewBuilder
    private var plainView: some View {
        if viewModel.visibleEntities.isEmpty {
            Text("No Recorded Logs")
                .font(.subheadline)
                .foregroundColor(.secondary)
        } else {
            ForEach(viewModel.visibleEntities, id: \.objectID) { entity in
                ConsoleEntityCell(entity: entity)
                    .onAppear { viewModel.onAppearCell(with: entity.objectID) }
                    .onDisappear { viewModel.onDisappearCell(with: entity.objectID) }
            }
        }
#if !os(macOS)
        footerView
#endif
    }

    @ViewBuilder
    private var footerView: some View {
        if #available(iOS 15, *), viewModel.isShowPreviousSessionButtonShown, !viewModel.isShowingFocusedEntities {
            Button(action: viewModel.buttonShowPreviousSessionTapped) {
                Text("Show Previous Sessions")
                    .font(.subheadline)
                    .foregroundColor(Color.blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
#if os(iOS)
            .listRowSeparator(.hidden, edges: .bottom)
#endif
        }
    }
}

private struct PinCellViewModel: Hashable, Identifiable {
    let object: NSManagedObject
    var id: PinCellId

    init(_ object: NSManagedObject) {
        self.object = object
        self.id = PinCellId(id: object.objectID)
    }
}

// Make sure the cells 
private struct PinCellId: Hashable {
    let id: NSManagedObjectID
}

#if os(iOS)
struct ConsolePlainList: View {
    @ObservedObject var viewModel: ConsoleListViewModel

    var body: some View {
        List {
            ForEach(viewModel.entities, id: \.objectID, content: ConsoleEntityCell.init)
        }
        .onAppear { viewModel.isViewVisible = true }
        .onDisappear { viewModel.isViewVisible = false }
        .listStyle(.plain)
    }
}

struct ConsoleStaticList: View {
    let entities: [NSManagedObject]

    var body: some View {
        List {
            ForEach(entities, id: \.objectID, content: ConsoleEntityCell.init)
        }
    }
}

private struct LazyConsoleView: View {
    let title: String
    let entities: [NSManagedObject]
    let source: ConsoleListViewModel

    var body: some View {
        ConsoleView(viewModel: makeViewModel())
            .navigationBarTitleDisplayMode(.inline)
    }

    private func makeViewModel() -> ConsoleViewModel {
        let viewModel = ConsoleViewModel(
            store: source.store,
            context: .init(title: title, focus: NSPredicate(format: "self IN %@", entities)),
            mode: source.mode
        )
        viewModel.listViewModel.options.order = source.options.order
        viewModel.listViewModel.options.messageSortBy = source.options.messageSortBy
        viewModel.listViewModel.options.taskSortBy = source.options.taskSortBy
        return viewModel
    }
}
#endif
