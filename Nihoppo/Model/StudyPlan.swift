//
//  StudyPlan.swift
//  Nihoppo
//
//  Created by Elena Angkawi on 08/09/26.
//

import Foundation
 
struct StudyPlan: Codable, Equatable {
    var days: [StudyDay]
}
 
struct StudyDay: Codable, Equatable, Identifiable {
    var dayNumber: Int
    var topic: String
    var description: String
    var activities: [StudyActivity]
 
    var id: Int { dayNumber }
 
    var totalMinutes: Int {
        activities.reduce(0) { $0 + $1.durationMinutes }
    }
}
 
struct StudyActivity: Codable, Equatable, Identifiable {
    var title: String
    var durationMinutes: Int
 
    var id: String { "\(title)-\(durationMinutes)" }
}
