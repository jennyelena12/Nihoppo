//
//  StudyModel.swift
//  Nihoppo
//
//  Created by Elena Angkawi on 04/09/26.
//

import SwiftUI
import SwiftData
import Observation

@Model
final class StudyCommitment {
    var dailyMinutes: Int
    var preferredHour: Int
    var preferredMinute: Int
 
    init(dailyMinutes: Int, preferredHour: Int, preferredMinute: Int) {
        self.dailyMinutes = dailyMinutes
        self.preferredHour = preferredHour
        self.preferredMinute = preferredMinute
    }
}
