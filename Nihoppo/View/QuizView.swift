//
//  QuizView.swift
//  Nihoppo
//
//  Created by Elena Angkawi on 03/09/26.
//

import SwiftUI

struct QuizView: View {
    @State private var viewModel: QuizViewModel

    init(questions: [Question]) {
        _viewModel = State(initialValue: QuizViewModel(questions: questions))
    }

    var body: some View {
        ZStack {
            Color.nihoppoCream.ignoresSafeArea()

            if let question = viewModel.currentQuestion {
                VStack(alignment: .leading, spacing: NihoppoSpacing.l) {

                    // Progress
                    VStack(alignment: .leading, spacing: NihoppoSpacing.xs) {
                        HStack {
                            Text(viewModel.progressText)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.nihoppoBlue)
                            Spacer()
//                            Image(systemName: "leaf.fill")
//                                .foregroundStyle(Color.nihoppoRed.opacity(0.6))
//                                .font(.caption)
                        }
                        NihoppoProgressBar(progress: progressFraction)
                    }

                    // Question card
                    NihoppoCard(padding: NihoppoSpacing.l) {
                        Text(question.questionText)
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .foregroundStyle(Color.nihoppoInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .id(question.questionText)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

                    // Answers
                    VStack(spacing: NihoppoSpacing.s) {
                        ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                            Button {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    viewModel.selectAnswer(index)
                                }
                            } label: {
                                AnswerRow(
                                    text: option,
                                    state: answerState(for: index, question: question)
                                )
                            }
                            .disabled(viewModel.isAnswered)
                        }
                    }

                    if viewModel.isAnswered {
                        FeedbackBanner(isCorrect: viewModel.selectedAnswerIndex == question.correctAnswerIndex)
                            .transition(.opacity.combined(with: .move(edge: .top)))

                        Button("Next Question") {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                viewModel.goToNextQuestion()
                            }
                        }
                        .buttonStyle(NihoppoPrimaryButtonStyle())
                    }

                    Spacer(minLength: 0)
                }
                .padding(NihoppoSpacing.m)
                .animation(.easeInOut(duration: 0.25), value: viewModel.isAnswered)
            } else {
                QuizCompleteView(
                    score: viewModel.score,
                    total: viewModel.questions.count,
                    onRestart: { viewModel.restart() },
                    quizResult: viewModel.result
                )
            }
        }
    }

    /// Best-effort progress fraction parsed from `progressText` (e.g. "Question 2 of 6").
    /// Falls back to 0 if the format can't be parsed, so the bar degrades gracefully
    /// without requiring any change to `QuizViewModel`.
    private var progressFraction: Double {
        let digits = viewModel.progressText.split(separator: " ").compactMap { Int($0) }
        guard digits.count == 2, digits[1] > 0 else { return 0 }
        return Double(digits[0] - 1) / Double(digits[1])
    }

    private func answerState(for index: Int, question: Question) -> AnswerRow.State {
        guard viewModel.isAnswered else { return .idle }
        if index == question.correctAnswerIndex {
            return .correct
        } else if index == viewModel.selectedAnswerIndex {
            return .incorrect
        } else {
            return .dimmed
        }
    }
}

// MARK: - Answer row

private struct AnswerRow: View {
    enum State { case idle, correct, incorrect, dimmed }

    let text: String
    let state: State

    var body: some View {
        HStack {
            Text(text)
                .font(.body.weight(.medium))
                .foregroundStyle(foreground)
                .multilineTextAlignment(.leading)
            Spacer()
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(foreground)
                    .font(.headline)
            }
        }
        .padding(NihoppoSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: NihoppoRadius.medium, style: .continuous)
                .fill(background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: NihoppoRadius.medium, style: .continuous)
                .strokeBorder(border, lineWidth: 1.5)
        )
        .opacity(state == .dimmed ? 0.5 : 1)
    }

    private var icon: String? {
        switch state {
        case .correct: return "checkmark.circle.fill"
        case .incorrect: return "face.smiling"
        default: return nil
        }
    }

    private var background: Color {
        switch state {
        case .idle: return Color.nihoppoCard
        case .correct: return Color.nihoppoMint
        case .incorrect: return Color.nihoppoPeach
        case .dimmed: return Color.nihoppoCard
        }
    }

    private var border: Color {
        switch state {
        case .idle: return Color.nihoppoBorder
        case .correct: return Color.green.opacity(0.45)
        case .incorrect: return Color.nihoppoRed.opacity(0.35)
        case .dimmed: return Color.nihoppoBorder.opacity(0.5)
        }
    }

    private var foreground: Color {
        switch state {
        case .correct: return Color(red: 0.16, green: 0.42, blue: 0.28)
        case .incorrect: return Color.nihoppoRed
        default: return Color.nihoppoInk
        }
    }
}

private struct FeedbackBanner: View {
    let isCorrect: Bool

    var body: some View {
        HStack(spacing: NihoppoSpacing.s) {
            Image(systemName: isCorrect ? "star.fill" : "hands.sparkles.fill")
                .foregroundStyle(isCorrect ? Color.nihoppoBlue : Color.nihoppoRed)
            Text(isCorrect ? "Nice! That's correct." : "Not quite — you'll get the next one!")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.nihoppoInk)
        }
        .padding(.vertical, NihoppoSpacing.s)
        .padding(.horizontal, NihoppoSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: NihoppoRadius.medium, style: .continuous)
                .fill((isCorrect ? Color.nihoppoMint : Color.nihoppoSunflower).opacity(0.6))
        )
    }
}


private struct QuizCompleteView: View {
    let score: Int
    let total: Int
    let onRestart: () -> Void
    let quizResult: QuizResult

    var body: some View {
        VStack(spacing: NihoppoSpacing.l) {
            Spacer()

            FoxMascotView(expression: .celebrating, size: 116)

            VStack(spacing: NihoppoSpacing.xs) {
                Text("Quiz complete!")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.nihoppoInk)
                Text("Great effort — every question helps us tailor your plan.")
                    .font(.subheadline)
                    .foregroundStyle(Color.nihoppoSecondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, NihoppoSpacing.l)
            }

            NihoppoCard {
                VStack(spacing: NihoppoSpacing.xs) {
                    Text("\(score) / \(total)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.nihoppoBlue)
                    Text("Your Score")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.nihoppoSecondaryText)
                        .textCase(.uppercase)
                        .tracking(1)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, NihoppoSpacing.l)

            Spacer()

            VStack(spacing: NihoppoSpacing.s) {
                NavigationLink("Continue") {
                    CommitmentSetupView(quizResult: quizResult)
                }
                .buttonStyle(NihoppoPrimaryButtonStyle())

                Button("Restart Quiz", action: onRestart)
                    .buttonStyle(NihoppoSecondaryButtonStyle())
            }
            .padding(.horizontal, NihoppoSpacing.l)
            .padding(.bottom, NihoppoSpacing.l)
        }
    }
}

#Preview {
    QuizView(questions: QuestionSeedData.all)
}
