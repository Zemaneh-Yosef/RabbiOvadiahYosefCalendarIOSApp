//
//  ZmanEntryInfoView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 10/13/26.
//

import SwiftUI
import ActivityKit

struct ZmanEntryInfoView: View {
    enum Action {
        case setupVisibleSunrise
        case showFullText(prayer: String)
        case showDatePicker
    }

    @Environment(\.dismiss) private var dismiss

    let type: ZmanListEntryType
    let alternateType: ZmanListEntryType?
    let entryTitle: String
    let zman: Date?
    let jewishMonth: Int
    let candleLightingOffset: String
    let defaults: UserDefaults
    let onAction: (Action) -> Void

    @State private var currentType: ZmanListEntryType
    @State private var showChoiceAlert = false

    init(type: ZmanListEntryType,
         alternateType: ZmanListEntryType? = nil,
         entryTitle: String,
         zman: Date?,
         jewishMonth: Int = 0,
         candleLightingOffset: String,
         defaults: UserDefaults,
         onAction: @escaping (Action) -> Void) {
        self.type = type
        self.alternateType = alternateType
        self.entryTitle = entryTitle
        self.zman = zman
        self.jewishMonth = jewishMonth
        self.candleLightingOffset = candleLightingOffset
        self.defaults = defaults
        self.onAction = onAction
        _currentType = State(initialValue: type)
    }

    private var info: ZmanimAlertInfoHolder {
        ZmanimAlertInfoHolder(type: currentType, jewishMonth: jewishMonth)
    }

    private var showsDatePicker: Bool { currentType == .jewishMonth }
    private var showsVisibleSunrise: Bool { currentType == .hanetzZman }
    private var showsBirchatHalevana: Bool { currentType == .birchatHalevana }
    private var showsOmer: Bool { currentType == .dayOfOmer }

    private var canStartLiveActivity: Bool {
        guard #available(iOS 16.2, *), ActivityAuthorizationInfo().areActivitiesEnabled else { return false }
        guard currentType == type, type.isZman, let zman else { return false }
        return zman > Date() && zman.timeIntervalSinceNow < 28800 // within the next 8 hours
    }

    private var hasActions: Bool {
        showsVisibleSunrise || showsBirchatHalevana || showsOmer || showsDatePicker || canStartLiveActivity
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    infoCard
                    if hasActions {
                        actionsCard
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(info.getFullTitle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Dismiss") { dismiss() }
                }
            }
            .alert("Which information would you like to see?", isPresented: $showChoiceAlert) {
                Button(ZmanimAlertInfoHolder(type: type).getFullTitle()) {
                    currentType = type
                }
                if let alternateType {
                    Button(ZmanimAlertInfoHolder(type: alternateType).getFullTitle()) {
                        currentType = alternateType
                    }
                }
                Button("Cancel", role: .cancel) { dismiss() }
            }
        }
        .onAppear {
            if alternateType != nil {
                showChoiceAlert = true
            }
        }
    }

    // MARK: - Cards

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(info.getFullTitle().addingShabbatOpinion(defaults: defaults), systemImage: "info.circle.fill")
                .font(.headline.bold())

            MarkdownSections(markdown: info.getFullMessage().replacingOccurrences(of: "%c", with: candleLightingOffset))
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

    private var actionsCard: some View {
        VStack(spacing: 12) {
            if showsVisibleSunrise {
                actionButton("Setup Visible Sunrise", icon: "sunrise.fill") {
                    perform(.setupVisibleSunrise)
                }
            }
            if showsBirchatHalevana {
                actionButton("Show Full Text", icon: "book.fill") {
                    perform(.showFullText(prayer: "Birchat Halevana"))
                }
            }
            if showsOmer {
                actionButton("Show Full Text", icon: "book.fill") {
                    perform(.showFullText(prayer: "Sefirat HaOmer"))
                }
            }
            if showsDatePicker {
                actionButton("Change Date", icon: "calendar") {
                    perform(.showDatePicker)
                }
            }
            if canStartLiveActivity {
                actionButton("Keep track of this zman with a Live Activity?", icon: "timer") {
                    if #available(iOS 16.2, *) {
                        startLiveActivity()
                    }
                    dismiss()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private func actionButton(_ title: LocalizedStringKey, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
        }
        .buttonStyle(ProminentActionButtonStyle())
    }
    
    private struct ProminentActionButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .foregroundColor(Color(UIColor.systemBackground))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.primary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .opacity(configuration.isPressed ? 0.7 : 1)
        }
    }

    // MARK: - Actions

    private func perform(_ action: Action) {
        onAction(action)
        dismiss()
    }

    @available(iOS 16.2, *)
    private func startLiveActivity() {
        let attributes = Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes(zmanName: entryTitle)
        let contentState = Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes.TimerStatus(endTime: zman ?? Date())
        _ = try? Activity<Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes>.request(
            attributes: attributes,
            content: ActivityContent(state: contentState, staleDate: nil),
            pushType: nil
        )
    }
}

struct Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes: ActivityAttributes {
    public typealias TimerStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var endTime: Date
    }

    // Fixed non-changing properties about your activity go here!
    var zmanName: String
}

#Preview {
    ZmanEntryInfoView(type: .unspecified, entryTitle: "Test", zman: Date(), candleLightingOffset: "20", defaults: UserDefaults.standard, onAction: { _ in })
}
