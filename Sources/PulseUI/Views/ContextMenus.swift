// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

#if os(iOS) || os(macOS)

import SwiftUI
import Pulse
import Combine

enum ContextMenu {
    @available(iOS 15, *)
    struct MessageContextMenu: View {
        let message: LoggerMessageEntity
        
        @Binding private(set) var shareItems: ShareItems?
        
        @EnvironmentObject private var filters: ConsoleFiltersViewModel
        
        var body: some View {
            Section {
                Button(action: { shareItems = ShareService.share(message, as: .plainText) }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }.tint(.blue)
                Button(action: { UXPasteboard.general.string = message.text }) {
                    Label("Copy Message", systemImage: "doc.on.doc")
                }.tint(.blue)
            }
            Section {
                Menu(content: {
                    Button("Hide Label '\(message.label)'") {
                        filters.criteria.messages.labels.hidden.insert(message.label)
                    }
                    Button("Hide Level '\(message.logLevel.name)'") {
                        filters.criteria.messages.logLevels.levels.remove(message.logLevel)
                    }
                }, label: {
                    Label("Hide", systemImage: "eye.slash")
                })
                Menu(content: {
                    Button("Show Label '\(message.label)'") {
                        filters.criteria.messages.labels.focused = message.label
                    }
                    Button("Show Level '\(message.logLevel.name)'") {
                        filters.criteria.messages.logLevels.levels = [message.logLevel]
                    }
                }, label: {
                    Label("Show", systemImage: "eye")
                })
            }
            Section {
                PinButton(viewModel: .init(message)).tint(.pink)
            }
        }
    }
    
    struct NetworkTaskContextMenuItems: View {
        let task: NetworkTaskEntity
#if os(iOS)
        @Binding private(set) var sharedItems: ShareItems?
#else
        @Binding private(set) var sharedTask: NetworkTaskEntity?
#endif
        
        var body: some View {
            Section {
#if os(iOS)
                if #available(iOS 14.0, *) {
                    ContextMenu.NetworkTaskShareMenu(task: task, shareItems: $sharedItems)
                }
#else
                Button(action: { sharedTask = task }) {
                    Label("Share...", systemImage: "square.and.arrow.up")
                }
#endif
                ContextMenu.NetworkTaskCopyMenu(task: task)
            }
            //            if environment.mode == .network {
            //                Section {
            //                    NetworkTaskFilterMenu(task: task)
            //                }
            //            }
            if let message = task.message {
                Section {
                    PinButton(viewModel: .init(message))
                }
            }
        }
    }
    
    struct NetworkTaskShareMenu: View {
        let task: NetworkTaskEntity
        @Binding var shareItems: ShareItems?
        
        var body: some View {
            if #available(iOS 14.0, *) {
                return Menu(content: content) {
                    Label("Share...", systemImage: "square.and.arrow.up")
                }
            } else {
                return Text("")
            }
        }
        
        @ViewBuilder
        private func content() -> some View {
            AttributedStringShareMenu(shareItems: $shareItems) {
                TextRenderer(options: .sharing).make {
                    $0.render(task, content: .sharing)
                }
            }
            if #available(iOS 14.0, *) {
                Button(action: { shareItems = ShareItems([task.cURLDescription()]) }) {
                    Label("Share as cURL", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
    
    struct NetworkTaskCopyMenu: View {
        let task: NetworkTaskEntity
        
        var body: some View {
            if #available(iOS 14.0, *) {
                Menu(content: content) {
                    Label("Copy...", systemImage: "doc.on.doc")
                }
            } else {
                Text("")
            }
        }
        
        @ViewBuilder
        private func content() -> some View {
            if #available(iOS 14.0, *) {
                if let url = task.url {
                    Button(action: {
                        UXPasteboard.general.string = url
                        runHapticFeedback()
                    }) {
                        Label("Copy URL", systemImage: "doc.on.doc")
                    }
                }
                if let host = task.host {
                    Button(action: {
                        UXPasteboard.general.string = host
                        runHapticFeedback()
                    }) {
                        Label("Copy Host", systemImage: "doc.on.doc")
                    }
                }
                if task.requestBodySize > 0 {
                    Button(action: {
                        guard let data = task.requestBody?.data else { return }
                        UXPasteboard.general.string = String(data: data, encoding: .utf8)
                        runHapticFeedback()
                    }) {
                        Label("Copy Request", systemImage:"arrow.up.circle")
                    }
                }
                if task.responseBodySize > 0 {
                    Button(action: {
                        guard let data = task.responseBody?.data else { return }
                        UXPasteboard.general.string = String(data: data, encoding: .utf8)
                        runHapticFeedback()
                    }) {
                        Label("Copy Response", systemImage: "arrow.down.circle")
                    }
                }
            } else {
                Text("")
            }
        }
    }
}

struct StringSearchOptionsMenu: View {
    @Binding private(set) var options: StringSearchOptions
    var isKindNeeded = true
    
#if os(macOS)
    var body: some View {
        Menu(content: { contents }, label: {
            Image(systemName: "ellipsis.circle")
        })
        .opacity(0.5)
        .pickerStyle(.inline)
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
    }
#else
    var body: some View {
        contents
    }
#endif
    
    @ViewBuilder
    private var contents: some View {
        Picker("Kind", selection: $options.kind) {
            ForEach(StringSearchOptions.Kind.allCases, id: \.self) {
                Text($0.rawValue).tag($0)
            }
        }
        Picker("Case Sensitivity", selection: $options.caseSensitivity) {
            ForEach(StringSearchOptions.CaseSensitivity.allCases, id: \.self) {
                Text($0.rawValue).tag($0)
            }
        }
        if let rules = options.allEligibleMatchingRules(), isKindNeeded {
            Picker("Matching Rule", selection: $options.rule) {
                ForEach(rules, id: \.self) {
                    Text($0.rawValue).tag($0)
                }
            }
        }
    }
}

struct AttributedStringShareMenu: View {
    @Binding var shareItems: ShareItems?
    let string: () -> NSAttributedString
    
    var body: some View {
        if #available(iOS 14.0, *) {
            Button(action: { shareItems = ShareService.share(string(), as: .plainText) }) {
                Label("Share as Text", systemImage: "square.and.arrow.up")
            }
            Button(action: { shareItems = ShareService.share(string(), as: .html) }) {
                Label("Share as HTML", systemImage: "square.and.arrow.up")
            }
#if os(iOS)
            Button(action: { shareItems = ShareService.share(string(), as: .pdf) }) {
                Label("Share as PDF", systemImage: "square.and.arrow.up")
            }
#endif
        } else {
            Text("")
        }
    }
}

#if DEBUG
struct StringSearchOptionsMenu_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            VStack(spacing: 32) {
                Spacer()
                Menu(content: {
                    AttributedStringShareMenu(shareItems: .constant(nil)) {
                        TextRenderer(options: .sharing).make { $0.render(LoggerStore.preview.entity(for: .login), content: .sharing) }
                    }
                }) {
                    Text("Attributed String Share")
                }
                Menu(content: {
                    Section(header: Label("Search Options", systemImage: "magnifyingglass")) {
                        StringSearchOptionsMenu(options: .constant(.default))
                    }
                }) {
                    Text("Search Options")
                }
            }
        } else {
            Text("")
        }
    }
}
#endif

#endif
