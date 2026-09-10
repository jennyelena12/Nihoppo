//
//  QuizViewModel.swift
//  Nihoppo
//
//  Created by Elena Angkawi on 04/09/26.
//

import Foundation
import Observation
 
struct AnsweredQuestion {
    let skill: QuestionSkill
    let level: ProficiencyLevel
    let wasCorrect: Bool
}
 
struct QuizResult {
    let score: Int
    let totalQuestions: Int
    let achievedLevel: ProficiencyLevel
    let weakAreas: [QuestionSkill]
}
 
@Observable
final class QuizViewModel{
    private(set) var questions: [Question]
    private(set) var currentIndex: Int = 0
    private(set) var selectedAnswerIndex: Int? = nil
    private(set) var isAnswered: Bool = false
    private(set) var score: Int = 0
    private(set) var answeredQuestions: [AnsweredQuestion] = []
    
    init(questions: [Question]){
        self.questions = questions
    }
    
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var isQuizComplete: Bool {
            currentIndex >= questions.count
        }
    
    var progressText: String {
            "\(min(currentIndex + 1, questions.count)) / \(questions.count)"
        }
 
    /// Snapshot of the quiz outcome, used to drive plan generation.
    var result: QuizResult {
        QuizResult(
            score: score,
            totalQuestions: questions.count,
            achievedLevel: achievedLevel(),
            weakAreas: weakAreas()
        )
    }
    
    func selectAnswer(_ index: Int) {
           guard !isAnswered, let question = currentQuestion else { return }
           selectedAnswerIndex = index
           isAnswered = true
           let wasCorrect = index == question.correctAnswerIndex
           if wasCorrect {
               score += 1
           }
           answeredQuestions.append(
               AnsweredQuestion(skill: question.skill, level: question.level, wasCorrect: wasCorrect)
           )
       }
    
    func goToNextQuestion() {
            guard isAnswered else { return }
            currentIndex += 1
            selectedAnswerIndex = nil
            isAnswered = false
        }
    
    func restart() {
        currentIndex = 0
        selectedAnswerIndex = nil
        isAnswered = false
        score = 0
        answeredQuestions = []
    }
 
    /// Skills answered below 60% accuracy — these get prioritized in the plan.
    private func weakAreas() -> [QuestionSkill] {
        let grouped = Dictionary(grouping: answeredQuestions, by: \.skill)
        return grouped.compactMap { skill, answers in
            let accuracy = Double(answers.filter(\.wasCorrect).count) / Double(answers.count)
            return accuracy < 0.6 ? skill : nil
        }
    }
 
    /// Highest level with >=60% accuracy, walking up from absolute beginner,
    /// stopping at the first level that isn't cleared.
    private func achievedLevel() -> ProficiencyLevel {
        let order: [ProficiencyLevel] = [.absoluteBeginner, .beginner, .elementary, .intermediate, .upperIntermediate]
        let grouped = Dictionary(grouping: answeredQuestions, by: \.level)
        var achieved: ProficiencyLevel = .absoluteBeginner
        for level in order {
            guard let answers = grouped[level], !answers.isEmpty else { continue }
            let accuracy = Double(answers.filter(\.wasCorrect).count) / Double(answers.count)
            if accuracy >= 0.6 {
                achieved = level
            } else {
                break
            }
        }
        return achieved
    }
}
