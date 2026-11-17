//
//  LimudEntryInfoView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 10/17/26.
//

import SwiftUI

struct LimudEntryInfoView: View {
    
    @Environment(\.dismiss) private var dismiss

    let entryTitle: String
    let entryDesc: String

    init(entryTitle: String, entryDesc: String) {
        self.entryTitle = entryTitle
        self.entryDesc = entryDesc
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Label(entryTitle, systemImage: "info.circle.fill")
                            .font(.headline.bold())

                        MarkdownSections(markdown: entryDesc)
                            .font(.subheadline)
                            .foregroundColor(.primary.opacity(0.8))
                            .lineSpacing(4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(entryTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Dismiss") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    LimudEntryInfoView(entryTitle: "", entryDesc: "")
}

