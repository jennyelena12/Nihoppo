//
//  StudyPlanGenerator.swift
//  Nihoppo
//
//  Created by Elena Angkawi on 08/09/26.
//



import Foundation

enum LLMProvider: String, CaseIterable, Identifiable {
    case appleFoundation = "Apple On-Device"
    case qwen = "Qwen 2.5"
    case llama = "Llama 3.2"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .appleFoundation:
            return "Apple's on-device Foundation Models framework"
        case .qwen:
            return "Qwen2.5 1.5B, quantized, runs locally via MLX"
        case .llama:
            return "Llama 3.2 1B, quantized, runs locally via MLX"
        }
    }
}

enum PlanGenerationError: Error, LocalizedError {
    case malformedResponse(String)
    case privateCloudComputeUnavailable

    var errorDescription: String? {
        switch self {
        case .malformedResponse(let raw):
            return "The model didn't return valid plan JSON. Raw output: \(raw.prefix(200))"
        case .privateCloudComputeUnavailable:
            return "Private Cloud Compute isn't available right now (needs an Apple Intelligence-eligible device, network, and the PCC entitlement)."
        }
    }
}

enum StudyPlanGenerator {
    static func generate(
        provider: LLMProvider,
        level: ProficiencyLevel,
        weakAreas: [QuestionSkill],
        dailyMinutes: Int
    ) async throws -> StudyPlan {
        let plan: StudyPlan
        switch provider {
        case .appleFoundation:
            plan = try await FoundationModelPlanGenerator()
                .generatePlan(level: level, weakAreas: weakAreas, dailyMinutes: dailyMinutes)
        case .qwen:
            plan = try await QwenPlanGenerator.shared
                .generatePlan(level: level, weakAreas: weakAreas, dailyMinutes: dailyMinutes)
        case .llama:
            plan = try await LLamaPlanGenerator.shared
                .generatePlan(level: level, weakAreas: weakAreas, dailyMinutes: dailyMinutes)
        }
        let repairedPlan = repaired(plan, totalDays: 7)
        return rescaled(repairedPlan, toDailyMinutes: dailyMinutes)
    }

    /// Fixes shape problems the model's raw output might have — wrong day
    /// count, duplicate/out-of-order day numbers, a day with zero activities
    /// (which `rescaled` can't fix since there's nothing to scale). This runs
    /// on every provider's output, not just the MLX ones, since none of them
    /// are guaranteed to hit the requested day count exactly. It does not try
    /// to fix content quality — only shape issues that would otherwise break
    /// the UI or the rescale step below.
    static func repaired(_ plan: StudyPlan, totalDays: Int) -> StudyPlan {
        var days = plan.days
        guard !days.isEmpty else { return plan }

        if days.count > totalDays {
            days = Array(days.prefix(totalDays))
        } else if days.count < totalDays, let lastDay = days.last {
            while days.count < totalDays {
                days.append(lastDay)
            }
        }

        days = days.enumerated().map { index, day in
            var activities = day.activities
            if activities.isEmpty {
                activities = [StudyActivity(title: "Review", durationMinutes: 10)]
            }
            return StudyDay(
                dayNumber: index + 1,
                topic: day.topic,
                description: day.description,
                activities: activities
            )
        }

        return StudyPlan(days: days)
    }

    /// Proportionally rescales each day's activity durations so they sum to
    /// exactly `dailyMinutes`, regardless of what the model actually returned.
    /// The @Guide description (and the prompt text) is only a hint to the
    /// model, not an enforced constraint — this makes the guarantee real.
    static func rescaled(_ plan: StudyPlan, toDailyMinutes dailyMinutes: Int) -> StudyPlan {
        guard dailyMinutes > 0 else { return plan }

        let days = plan.days.map { day -> StudyDay in
            let total = day.activities.reduce(0) { $0 + $1.durationMinutes }
            guard total != dailyMinutes, total > 0, !day.activities.isEmpty else {
                return day
            }

            let scale = Double(dailyMinutes) / Double(total)

            var scaled = day.activities.map { activity in
                let exactScaled = Double(activity.durationMinutes) * scale

                // Snap to the nearest 5-minute interval
                let roundedToFive = Int((exactScaled / 5.0).rounded() * 5.0)

                return StudyActivity(
                    title: activity.title,
                    durationMinutes: max(5, roundedToFive) // Ensure a minimum of 5 minutes
                )
            }

            // Rounding can leave the sum off by a few minutes — push the
            // remainder onto the longest activity so the total is exact.
            let scaledTotal = scaled.reduce(0) { $0 + $1.durationMinutes }
            let remainder = dailyMinutes - scaledTotal
            if remainder != 0, let longestIndex = scaled.indices.max(by: { scaled[$0].durationMinutes < scaled[$1].durationMinutes }) {
                let adjusted = max(5, scaled[longestIndex].durationMinutes + remainder)
                scaled[longestIndex] = StudyActivity(title: scaled[longestIndex].title, durationMinutes: adjusted)
            }

            return StudyDay(
                dayNumber: day.dayNumber,
                topic: day.topic,
                description: day.description,
                activities: scaled
            )
        }

        return StudyPlan(days: days)
    }

    /// Shared instructions text so all providers are prompted consistently.
    static func promptInstructions(level: ProficiencyLevel, weakAreas: [QuestionSkill], dailyMinutes: Int) -> String {
        let weak = weakAreas.map(\.rawValue).joined(separator: ", ")
        return """
        You are a Japanese language tutor creating a 7-day study plan.
        Student level: \(level.rawValue).
        Weak areas to prioritize: \(weak.isEmpty ? "none identified, cover a balanced mix of skills" : weak).
        Daily commitment: \(dailyMinutes) minutes.

        Rules:
        - Produce exactly 7 days, numbered 1 through 7.
        - Each day's activities must sum to exactly \(dailyMinutes) minutes.
        - Reuse and reinforce material across days rather than introducing something new every day.
        - Progress gradually in difficulty across the week.
        - Keep topic names short (a few words) and descriptions to one or two sentences.
        """
    }
    static func fewShotExample() -> String {
        """

        Example of the exact shape to output (illustrative content only — replace it with content matching this student's actual level and weak areas, don't reuse it verbatim):
        {"days":[{"dayNumber":1,"topic":"Hiragana Review","description":"Warm up with hiragana recognition and reinforce basic greeting vocabulary.","activities":[{"title":"Hiragana flashcards","durationMinutes":10},{"title":"Greetings vocabulary drill","durationMinutes":10}]}]}
        """
    }
}
