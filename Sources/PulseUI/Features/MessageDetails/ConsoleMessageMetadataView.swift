// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse

@available(iOS 14.0, *)
struct ConsoleMessageMetadataView: View {
    let message: LoggerMessageEntity

    var body: some View {
        if #available(iOS 14.0, *) {
            RichTextView(viewModel: .init(string: string))
#if !os(macOS)
                .navigationTitle("Message Details")
#endif
        } else {
            Text("")
        }
    }

    private var string: NSAttributedString {
        let renderer = TextRenderer()
        renderer.render(sections)
        return renderer.make()
    }

    private var sections: [KeyValueSectionViewModel] {
        return [
            KeyValueSectionViewModel(title: "Summary", color: .textColor(for: message.logLevel), items: [
                ("Date", DateFormatter.fullDateFormatter.string(from: message.createdAt)),
                ("Level", LoggerStore.Level(rawValue: message.level)?.name),
                ("Label", message.label.nonEmpty)
            ]),
            KeyValueSectionViewModel(title: "Details", color: .primary, items: [
                ("File", message.file.nonEmpty),
                ("Function", message.function.nonEmpty),
                ("Line", message.line == 0 ? nil : "\(message.line)"),
            ]),
            KeyValueSectionViewModel(title: "Metadata", color: .indigo, items: metadataItems)
        ]
    }

    private var metadataItems: [(String, String?)] {
        message.metadata.sorted(by: { $0.key < $1.key }).map { ($0.key, $0.value )}
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}

#if DEBUG
@available(iOS 14.0, *)
struct ConsoleMessageMetadataView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            NavigationView {
                ConsoleMessageMetadataView(message: makeMockMessage())
            }
        } else {
            Text("")
        }
    }
}
#endif
