//
//  MarkdownText.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 10/14/26.
//

import SwiftUI

struct MarkdownText: View {
    let markdown: String

    var body: some View {
        Text(attributed)
    }

    private var attributed: AttributedString {
        let withBullets = markdown.replacingOccurrences(
            of: "(?m)^\\s*[-*] ",
            with: "• ",
            options: .regularExpression
        )
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        return (try? AttributedString(markdown: withBullets, options: options))
            ?? AttributedString(withBullets)
    }
}

/// Splits on lines containing only `---` and shows a Divider between the sections.
struct MarkdownSections: View {
    let markdown: String

    private var sections: [String] {
        var groups: [[String]] = [[]]
        for line in markdown.components(separatedBy: .newlines) {
            if line.trimmingCharacters(in: .whitespaces) == "---" {
                groups.append([])
            } else {
                groups[groups.count - 1].append(line)
            }
        }
        return groups
            .map { $0.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(sections.indices, id: \.self) { index in
                if index > 0 {
                    Divider()
                }
                MarkdownText(markdown: sections[index])
            }
        }
    }
}
