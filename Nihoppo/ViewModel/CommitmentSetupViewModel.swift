//
//  CommitmentSetupViewModel.swift
//  Nihoppo
//
//  Created by Elena Angkawi on 04/09/26.
//

import Foundation
import SwiftData
 
struct CommitmentSummary: Identifiable, Hashable {
    let id = UUID()
    let dailyMinutes: Int
    let startTime: Date
}
 
@Observable
final class CommitmentSetupViewModel {
    var selectedMinutes: Int = 20
    var selectedTime: Date = Calendar.current.date(
        bySettingHour: 18, minute: 0, second: 0, of: .now
    ) ?? .now
 
    private(set) var summary: CommitmentSummary?
 
    private let modelContext: ModelContext
 
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
 
    func save() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
        let commitment = StudyCommitment(
            dailyMinutes: selectedMinutes,
            preferredHour: components.hour ?? 18,
            preferredMinute: components.minute ?? 0
        )
        modelContext.insert(commitment)
        try? modelContext.save()
 
        summary = CommitmentSummary(dailyMinutes: selectedMinutes, startTime: selectedTime)
    }
}
