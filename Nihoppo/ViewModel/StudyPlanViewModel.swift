//
//  StudyPlanViewModel.swift
//  Nihoppo
//
//  Created by Elena Angkawi on 08/09/26.
//

import Foundation
import EventKit
import Observation
 
@MainActor
@Observable
final class StudyPlanViewModel {
    let quizResult: QuizResult
    let summary: CommitmentSummary
 
    var selectedProvider: LLMProvider = .appleFoundation
    var plan: StudyPlan?
    var isGenerating = false
    var errorMessage: String?
 
    let calendarService = CalendarService()
    var selectedCalendar: EKCalendar?
    var startDate: Date = .now
    var dailyStartTime: Date
    var dailyEndTime: Date
    var eventsCreated: Int?

  
    private var modelPreparationTask: Task<Void, Never>?
 
    init(quizResult: QuizResult, summary: CommitmentSummary) {
        self.quizResult = quizResult
        self.summary = summary
        self.dailyStartTime = summary.startTime
        self.dailyEndTime = Calendar.current.date(
            byAdding: .minute, value: summary.dailyMinutes, to: summary.startTime
        ) ?? summary.startTime
    }
 
    func generatePlan() async {
        isGenerating = true
        errorMessage = nil
        do {
            plan = try await StudyPlanGenerator.generate(
                provider: selectedProvider,
                level: quizResult.achievedLevel,
                weakAreas: quizResult.weakAreas,
                dailyMinutes: summary.dailyMinutes
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isGenerating = false
    }

    func scheduleModelPreparation(for provider: LLMProvider) {
        modelPreparationTask?.cancel()
        modelPreparationTask = Task { [weak self] in
            await self?.prepareModel(for: provider)
        }
    }

    private func prepareModel(for provider: LLMProvider) async {
        switch provider {
        case .appleFoundation:
            await QwenPlanGenerator.shared.unload()
            await LLamaPlanGenerator.shared.unload()
        case .qwen:
            await LLamaPlanGenerator.shared.unload()
            guard !Task.isCancelled else { return }
            await QwenPlanGenerator.shared.preload()
        case .llama:
            await QwenPlanGenerator.shared.unload()
            guard !Task.isCancelled else { return }
            await LLamaPlanGenerator.shared.preload()
        }
    }
 
    func requestCalendarAccess() async {
        await calendarService.requestAccess()
        selectedCalendar = calendarService.availableCalendars.first
    }
 
    func addToCalendar() {
        guard let plan, let selectedCalendar else { return }
        eventsCreated = calendarService.addEvents(
            for: plan,
            startDate: startDate,
            dailyStartTime: dailyStartTime,
            dailyEndTime: dailyEndTime,
            calendar: selectedCalendar
        )
    }
}
