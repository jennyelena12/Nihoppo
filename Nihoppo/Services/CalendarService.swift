//
//  CalendarService.swift
//  Nihoppo
//
//  Created by Elena Angkawi on 08/09/26.
//

import EventKit
import Observation

@MainActor
@Observable
final class CalendarService {
    private let eventStore = EKEventStore()

    private(set) var accessGranted = false
    private(set) var availableCalendars: [EKCalendar] = []

    func requestAccess() async {
        do {
            accessGranted = try await eventStore.requestFullAccessToEvents()
            if accessGranted {
                availableCalendars = eventStore.calendars(for: .event)
            }
        } catch {
            accessGranted = false
        }
    }

    /// Creates one event per day, anchored to `startDate`
    @discardableResult
    func addEvents(
        for plan: StudyPlan,
        startDate: Date,
        dailyStartTime: Date,
        dailyEndTime: Date,
        calendar: EKCalendar
    ) -> Int {
        let cal = Calendar.current
        var created = 0

        for day in plan.days.sorted(by: { $0.dayNumber < $1.dayNumber }) {
            guard let dayDate = cal.date(byAdding: .day, value: day.dayNumber - 1, to: startDate) else {
                continue
            }
            let startComponents = cal.dateComponents([.hour, .minute], from: dailyStartTime)
            let endComponents = cal.dateComponents([.hour, .minute], from: dailyEndTime)
            guard
                let eventStart = cal.date(bySettingHour: startComponents.hour ?? 7, minute: startComponents.minute ?? 0, second: 0, of: dayDate),
                let eventEnd = cal.date(bySettingHour: endComponents.hour ?? 8, minute: endComponents.minute ?? 0, second: 0, of: dayDate)
            else { continue }

            let event = EKEvent(eventStore: eventStore)
            event.title = "Japanese: \(day.topic)"
            event.startDate = eventStart
            event.endDate = eventEnd
            event.calendar = calendar
            event.notes = day.description + "\n\n" + day.activities
                .map { "• \($0.title) (\($0.durationMinutes) min)" }
                .joined(separator: "\n")

            do {
                try eventStore.save(event, span: .thisEvent)
                created += 1
            } catch {
                continue
            }
        }
        return created
    }
}
