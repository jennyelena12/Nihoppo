//
//  StudyPlanView.swift
//  Nihoppo
//
//  Created by Elena Angkawi on 08/09/26.
//

import SwiftUI
import EventKit

struct StudyPlanView: View {
    @State private var viewModel: StudyPlanViewModel

    init(quizResult: QuizResult, summary: CommitmentSummary) {
        _viewModel = State(initialValue: StudyPlanViewModel(quizResult: quizResult, summary: summary))
    }

    var body: some View {
        ZStack {
            Color.nihoppoCream.ignoresSafeArea()

            ScrollView {
                VStack(spacing: NihoppoSpacing.l) {
                    LearningAssistantSection(viewModel: viewModel)

                    if viewModel.isGenerating {
                        GeneratingStateView()
                    } else if let plan = viewModel.plan {
                        VStack(spacing: NihoppoSpacing.m) {
                            ForEach(plan.days) { day in
                                NihoppoCard {
                                    VStack(alignment: .leading, spacing: NihoppoSpacing.s) {
                                        HStack(alignment: .firstTextBaseline, spacing: NihoppoSpacing.s) {
                                            Text("DAY \(day.dayNumber)")
                                                .font(.caption.weight(.bold))
                                                .tracking(1)
                                                .padding(.horizontal, NihoppoSpacing.s)
                                                .padding(.vertical, 4)
                                                .background(Capsule().fill(Color.nihoppoBlue))
                                                .foregroundStyle(.white)

                                            Text(day.topic)
                                                .font(.system(.headline, design: .rounded))
                                                .foregroundStyle(Color.nihoppoInk)
                                        }

                                        Text(day.description)
                                            .font(.subheadline)
                                            .foregroundStyle(Color.nihoppoSecondaryText)
                                            .fixedSize(horizontal: false, vertical: true)

                                        VStack(spacing: NihoppoSpacing.xs) {
                                            ForEach(Array(day.activities.enumerated()), id: \.element.id) { index, activity in
                                                ActivityChip(
                                                    title: activity.title,
                                                    minutes: activity.durationMinutes,
                                                    tint: Color.nihoppoPastels[index % Color.nihoppoPastels.count]
                                                )
                                            }
                                        }
                                        .padding(.top, NihoppoSpacing.xs)
                                    }
                                }
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))

                        CalendarSection(viewModel: viewModel, dayCount: plan.days.count)
                    } else {
                        EmptyPlanStateView()
                    }
                }
                .padding(NihoppoSpacing.m)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isGenerating)
                .animation(.easeInOut(duration: 0.3), value: viewModel.plan != nil)
            }
        }
        .navigationTitle("Study Plan")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LearningAssistantSection: View {
    @Bindable var viewModel: StudyPlanViewModel

    var body: some View {
        NihoppoCard {
            VStack(alignment: .leading, spacing: NihoppoSpacing.m) {
                Label("Learning Assistant", systemImage: "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.nihoppoInk)

                Picker("Learning Assistant", selection: $viewModel.selectedProvider) {
                    ForEach(LLMProvider.allCases) { provider in
                        Text(provider.rawValue).tag(provider)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.selectedProvider) { _, newProvider in
                    viewModel.scheduleModelPreparation(for: newProvider)
                }

                ProviderSummaryRow(provider: viewModel.selectedProvider)

                Button {
                    Task { await viewModel.generatePlan() }
                } label: {
                    if viewModel.isGenerating {
                        HStack(spacing: NihoppoSpacing.s) {
                            ProgressView()
                                .tint(.white)
                            Text("Generating…")
                        }
                    } else {
                        Label(viewModel.plan == nil ? "Generate 7-Day Plan" : "Regenerate Plan", systemImage: "wand.and.stars")
                    }
                }
                .buttonStyle(NihoppoPrimaryButtonStyle(isDisabled: viewModel.isGenerating))
                .disabled(viewModel.isGenerating)

                if let errorMessage = viewModel.errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.nihoppoRed)
                }
            }
        }
    }
}


private struct ProviderSummaryRow: View {
    let provider: LLMProvider

    var body: some View {
        HStack(alignment: .top, spacing: NihoppoSpacing.s) {
            ZStack {
                Circle().fill(badge.tint).frame(width: 38, height: 38)
                badge.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20) // This frame replaces the old .font size
                        .foregroundStyle(Color.nihoppoInk)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(provider.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.nihoppoInk)
                Text(badge.strength)
                    .font(.caption)
                    .foregroundStyle(Color.nihoppoSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var badge: (image: Image, tint: Color, strength: String) {
        let name = provider.rawValue.lowercased()
        
        if name.contains("apple") || name.contains("device") {
            return (Image("FoundationModels"), .nihoppoMint,
                    "Strong general reasoning and instruction-following. Cloud-based — needs a connection.")
        } else if name.contains("qwen") {
            return (Image("Qwen"), .nihoppoLavender,
                    "Especially strong multilingual support, including Japanese. Efficient enough to run locally.")
        } else if name.contains("llama") || name.contains("meta") {
            return (Image("LLama"), .nihoppoSky,
                    "Open-weight and lightweight — runs fully on-device for private, offline use, trading some reasoning power for speed.")
        } else {
            return (Image(systemName: "cpu.fill"), .nihoppoSky, provider.subtitle)
        }
    }
}


private struct EmptyPlanStateView: View {
    var body: some View {
        VStack(spacing: NihoppoSpacing.m) {
            FoxMascotView(expression: .thinking, size: 88)
            Text("Your plan will appear here")
                .font(.headline)
                .foregroundStyle(Color.nihoppoInk)
            Text("Tap “Generate 7-Day Plan” above and Nihoppo will build a routine based on your quiz results and daily commitment.")
                .font(.subheadline)
                .foregroundStyle(Color.nihoppoSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, NihoppoSpacing.l)
        }
        .padding(.vertical, NihoppoSpacing.xl)
        .frame(maxWidth: .infinity)
    }
}

private struct GeneratingStateView: View {
    var body: some View {
        VStack(spacing: NihoppoSpacing.m) {
            FoxMascotView(expression: .thinking, size: 88)
            ProgressView()
            Text("Creating your personalized plan…")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.nihoppoSecondaryText)
        }
        .padding(.vertical, NihoppoSpacing.xl)
        .frame(maxWidth: .infinity)
    }
}


private struct ActivityChip: View {
    let title: String
    let minutes: Int
    let tint: Color

    var body: some View {
        HStack(spacing: NihoppoSpacing.s) {
            ZStack {
                Circle().fill(tint).frame(width: 30, height: 30)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.nihoppoInk)
            }
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.nihoppoInk)
            Spacer()
            Text("\(minutes) min")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.nihoppoSecondaryText)
        }
        .padding(.vertical, NihoppoSpacing.s)
        .padding(.horizontal, NihoppoSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: NihoppoRadius.small, style: .continuous)
                .fill(tint.opacity(0.35))
        )
    }

    private var icon: String {
        let lower = title.lowercased()
        if lower.contains("writ") { return "pencil.and.outline" }
        if lower.contains("pronun") || lower.contains("listen") || lower.contains("audio") { return "waveform" }
        if lower.contains("read") { return "book.fill" }
        if lower.contains("review") { return "arrow.triangle.2.circlepath" }
        if lower.contains("vocab") { return "textformat.abc" }
        if lower.contains("grammar") { return "text.book.closed.fill" }
        if lower.contains("speak") || lower.contains("convers") { return "bubble.left.and.bubble.right.fill" }
        if lower.contains("quiz") || lower.contains("test") { return "checkmark.seal.fill" }
        return "book.pages.fill"
    }
}


private struct CalendarSection: View {
    @Bindable var viewModel: StudyPlanViewModel
    let dayCount: Int

    var body: some View {
        NihoppoCard {
            VStack(alignment: .leading, spacing: NihoppoSpacing.m) {
                Label("Add to Calendar", systemImage: "calendar.badge.plus")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.nihoppoInk)

                VStack(spacing: NihoppoSpacing.s) {
                    DatePicker("Start date (Day 1)", selection: $viewModel.startDate, displayedComponents: .date)
                    DatePicker("Daily start time", selection: $viewModel.dailyStartTime, displayedComponents: .hourAndMinute)
                    DatePicker("Daily end time", selection: $viewModel.dailyEndTime, displayedComponents: .hourAndMinute)
                }
                .tint(Color.nihoppoBlue)

                if viewModel.calendarService.accessGranted {
                    Picker("Calendar", selection: $viewModel.selectedCalendar) {
                        ForEach(viewModel.calendarService.availableCalendars, id: \.calendarIdentifier) { calendar in
                            Text(calendar.title).tag(Optional(calendar))
                        }
                    }
                    .tint(Color.nihoppoBlue)

                    Button("Add \(dayCount) Events") {
                        viewModel.addToCalendar()
                    }
                    .buttonStyle(NihoppoPrimaryButtonStyle(tint: .nihoppoRed, isDisabled: viewModel.selectedCalendar == nil))
                    .disabled(viewModel.selectedCalendar == nil)
                } else {
                    Button("Allow Calendar Access") {
                        Task { await viewModel.requestCalendarAccess() }
                    }
                    .buttonStyle(NihoppoSecondaryButtonStyle())
                }

                if let created = viewModel.eventsCreated {
                    Label("Added \(created) events to your calendar.", systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color(red: 0.16, green: 0.42, blue: 0.28))
                }
            }
        }
    }
}


