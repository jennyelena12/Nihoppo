//
//  MLXPlanGenerator.swift
//  Nihoppo
//
//  Created by Elena Angkawi on 08/09/26.
//

import Foundation
import MLX
import MLXLMCommon
import MLXLLM
import MLXHuggingFace
import HuggingFace
import Tokenizers

actor QwenPlanGenerator {

    static let shared = QwenPlanGenerator()

    private let modelId = "mlx-community/Qwen2.5-1.5B-Instruct-4bit"
    private var modelContainer: ModelContainer?

    private func getContainer() async throws -> ModelContainer {
        if let container = modelContainer {
            return container
        }
        let config = ModelConfiguration(id: modelId)
        let container = try await #huggingFaceLoadModelContainer(configuration: config)
 
        try Task.checkCancellation()
        self.modelContainer = container
        return container
    }


    func preload() async {
        _ = try? await getContainer()
    }

    func unload() {
        modelContainer = nil
        Memory.clearCache()
    }

    func generatePlan(
        level: ProficiencyLevel,
        weakAreas: [QuestionSkill],
        dailyMinutes: Int,
        totalDays: Int = 7
    ) async throws -> StudyPlan {
        // Check cancellation before triggering heavy model loads
        try Task.checkCancellation()
        let container = try await getContainer()
        
        let instructions = StudyPlanGenerator.promptInstructions(
            level: level, weakAreas: weakAreas, dailyMinutes: dailyMinutes
        )
        
        let initialPrompt = instructions + """
        \nCRITICAL INSTRUCTIONS:
        1. You MUST respond entirely in English.
        2. You MUST generate exactly \(totalDays) days of activities. Do not stop at Day 1.
        3. Each day MUST contain multiple activities in the array (e.g., 2 to 3 activities).
        4. The `durationMinutes` MUST be rounded to standard intervals: 5, 10, 15, 20, or 30.
        5. Respond with ONLY raw JSON, no markdown fences, no commentary, matching exactly this shape:
                {"days":[{"dayNumber":1,"topic":"...","description":"...","activities":[{"title":"...","durationMinutes":10},{"title":"...","durationMinutes":15}]}]}
        """ + StudyPlanGenerator.fewShotExample()
        
        let generateParams = GenerateParameters(
            maxTokens: 2048, temperature: 0.3
                )
        
        // 2. First Attempt
        try Task.checkCancellation()
        let session = ChatSession(container, generateParameters: generateParams)
        let rawOutput = try await session.respond(to: initialPrompt)
        
        do {
            return try decode(rawOutput)
        } catch {
            // 3. One-time Retry with Stricter Prompt
            try Task.checkCancellation()
            let strictPrompt = initialPrompt + """
            \nCRITICAL ERROR: Your previous response was invalid JSON. 
            You MUST output ONLY parseable JSON. Do not include ```json tags.
            """
            
            // Initialize a fresh ChatSession so the model's context
            // isn't polluted by its previous malformed response
            let retrySession = ChatSession(container)
            let retryOutput = try await retrySession.respond(to: strictPrompt)
            
            return try decode(retryOutput)
        }
    }
    
    // 4. Robust JSON Parsing (nonisolated since it doesn't mutate actor state)
    nonisolated private func decode(_ raw: String) throws -> StudyPlan {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Smaller models (like 1.5B) frequently ignore "no markdown" instructions.
        // Strip out the fences manually if they exist.
        if text.hasPrefix("```json") {
            text = String(text.dropFirst(7)).trimmingCharacters(in: .whitespacesAndNewlines)
        } else if text.hasPrefix("```") {
            text = String(text.dropFirst(3)).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if text.hasSuffix("```") {
            text = String(text.dropLast(3)).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Isolate the dictionary
        if let start = text.firstIndex(of: "{"), let end = text.lastIndex(of: "}") {
            text = String(text[start...end])
        }
        
        guard let data = text.data(using: .utf8) else {
            throw PlanGenerationError.malformedResponse(raw)
        }
        
        do {
            return try JSONDecoder().decode(StudyPlan.self, from: data)
        } catch {
            throw PlanGenerationError.malformedResponse(raw)
        }
    }
}
