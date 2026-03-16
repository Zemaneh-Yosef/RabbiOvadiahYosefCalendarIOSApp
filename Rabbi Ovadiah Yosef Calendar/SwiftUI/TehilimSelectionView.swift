//
//  TehilimSelectionView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 3/8/26.
//

import Foundation
import SwiftUI
import KosherSwift

struct TehilimSelectionView: View {

    var openChapter: (Int) -> Void
    let bookStartChapters: Set<Int> = [1, 42, 73, 90, 107]
    let formatter = HebrewDateFormatter()
    
    init(openChapter: @escaping (Int) -> Void) {
        self.openChapter = openChapter
        formatter.useGershGershayim = false
    }
    
    func getBookNumber(index: Int) -> String {
        let book = Locale.isHebrewLocale() ? "ספר" : "Book"
        
        let mapping = [1: 1, 42: 2, 73: 3, 90: 4, 107: 5] // Mapping start chapters to Book numbers
        let bookIndex = mapping[index] ?? index
        
        let indexString = Locale.isHebrewLocale()
            ? formatter.formatHebrewNumber(number: bookIndex)
            : String(bookIndex)
            
        return "\(book) \(indexString)"
    }
    
    func formattedTehilimText(_ chapter: TehilimChapter) -> AttributedString {
        let words = chapter.text.removingNekudot().split(separator: " ")
        let big = words.prefix(chapter.bigWords).joined(separator: " ")
        let rest = words.dropFirst(chapter.bigWords).joined(separator: " ")

        var result = AttributedString()

        var bigPart = AttributedString(big)
        bigPart.font = .custom("ShofarRegular", size: 22)

        var restPart = AttributedString(rest.isEmpty ? "" : " " + rest)
        restPart.font = .custom("ShofarRegular", size: 16)

        result.append(bigPart)
        result.append(restPart)
        return result
    }

    var body: some View {
        List {
            ForEach(Array(TehilimFactory.chapters.enumerated()), id: \.offset) { index, chapter in
                
                // Check if this chapter starts a new book
                if bookStartChapters.contains(index + 1) {
                    Section {
                        // This section remains empty, the following chapters will appear under it
                    } header: {
                        VStack {
                            Text(getBookNumber(index: index + 1)).textCase(nil)
                        }
                    }
                }
                
                Button {
                    openChapter(index + 1)
                } label: {
                    HStack(spacing: 2) {
                        // 1. LEFT: Arabic Number (Locked width to prevent middle text swaying)
                        Text(String(index + 1))
                            .font(.system(size: 24))
                            .frame(width: 50, alignment: .leading)

                        // 2. MIDDLE: Tehillim Text
                        // Note: .leading alignment in LTR is the "Start"
                        Text(formattedTehilimText(chapter))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .trailing)

                        // 3. RIGHT: Hebrew Chapter (Placeholder strategy)
                        ZStack {
                            Text("קכטט")
                                .font(.custom("GuttmanMantovaBold", size: 24))
                                .opacity(0)

                            Text(formatter.formatHebrewNumber(number: index + 1))
                                .font(.custom("GuttmanMantovaBold", size: 24))
                        }
                        .frame(width: 70, alignment: .center)
                    }
                    .environment(\.layoutDirection, .leftToRight)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("תהלים")
    }
}
