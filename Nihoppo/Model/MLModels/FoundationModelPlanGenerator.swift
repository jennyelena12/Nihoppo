//
//  FoundationModelPlanGenerator.swift
//  Nihoppo
//
//  Created by Elena Angkawi on 08/09/26.
//

import FoundationModels
 
struct FoundationModelPlanGenerator {
    func generatePlan(
        level: ProficiencyLevel,
        weakAreas: [QuestionSkill],
        dailyMinutes: Int
    ) async throws -> StudyPlan {
        let instructions = StudyPlanGenerator.promptInstructions(
            level: level, weakAreas: weakAreas, dailyMinutes: dailyMinutes
        )
        let session = LanguageModelSession(instructions: instructions)
        let response = try await session.respond(
            to: "Generate the 7-day plan now.",
            generating: GeneratedPlan.self
        )
        return response.content.asStudyPlan
    }
}
 

@Generable
struct GeneratedPlan {
    @Guide(description: "Exactly 7 days of study plan, day 1 through day 7, in order")
    var days: [GeneratedDay]
}
 
@Generable
struct GeneratedDay {
    @Guide(description: "Day number, 1 through 7")
    var dayNumber: Int
    @Guide(description: "Short topic name for the day, e.g. 'Hiragana Review + Basic Particles'")
    var topic: String
    @Guide(description: "One or two sentence description of what this day covers and why")
    var description: String
    @Guide(description: "Timed activities for the day; their durations should sum to the daily commitment")
    var activities: [GeneratedActivity]
}
 
@Generable
struct GeneratedActivity {
    @Guide(description: "Short activity name, e.g. 'Vocabulary review'")
    var title: String
    @Guide(description: "Duration of this activity in minutes")
    var durationMinutes: Int
}
 
// Internal (not private) so PrivateCloudComputePlanGenerator can reuse
// this mapping — both providers produce the same @Generable mirror type.
extension GeneratedPlan {
    var asStudyPlan: StudyPlan {
        StudyPlan(days: days.map { day in
            StudyDay(
                dayNumber: day.dayNumber,
                topic: day.topic,
                description: day.description,
                activities: day.activities.map {
                    StudyActivity(title: $0.title, durationMinutes: $0.durationMinutes)
                }
            )
        })
    }
}
