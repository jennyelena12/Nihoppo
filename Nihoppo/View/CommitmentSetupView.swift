//
//  CommitmentSetupView.swift
//  Nihoppo
//
//  Created by Elena Angkawi on 04/09/26.
//
import SwiftUI
import Foundation
import SwiftData


struct CommitmentSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: CommitmentSetupViewModel?
    @State private var savedSummary: CommitmentSummary?
    let quizResult: QuizResult

    var body: some View {
        ZStack {
            Color.nihoppoCream.ignoresSafeArea()

            if let viewModel {
                ScrollView {
                    VStack(spacing: NihoppoSpacing.m) {

                        VStack(spacing: NihoppoSpacing.xs) {
                            FoxMascotView(size: 72)
                            Text("Build your routine")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.nihoppoInk)
                            Text("Small steps every day add up.")
                                .font(.subheadline)
                                .foregroundStyle(Color.nihoppoSecondaryText)
                        }
                        .padding(.top, NihoppoSpacing.m)

                        // Daily minutes
                        NihoppoCard {
                            VStack(spacing: NihoppoSpacing.s) {
                                HStack {
                                    Label("How much time can you learn each day?", systemImage: "clock.fill")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.nihoppoInk)
                                    Spacer()
                                }

                                Text("\(viewModel.selectedMinutes) min")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.nihoppoBlue)

                                Picker("Minutes per day", selection: Bindable(viewModel).selectedMinutes) {
                                    ForEach(Array(stride(from: 5, through: 120, by: 5)), id: \.self) { minute in
                                        Text("\(minute) min").tag(minute)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: NihoppoRadius.medium, style: .continuous))
                                .background(
                                    RoundedRectangle(cornerRadius: NihoppoRadius.medium, style: .continuous)
                                        .fill(Color.nihoppoSky.opacity(0.35))
                                )
                            }
                        }

                        // Start time
                        NihoppoCard {
                            VStack(spacing: NihoppoSpacing.s) {
                                HStack {
                                    Label("What time works best?", systemImage: "sun.max.fill")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.nihoppoInk)
                                    Spacer()
                                }

                                Text(viewModel.selectedTime, style: .time)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.nihoppoRed)

                                DatePicker(
                                    "Time",
                                    selection: Bindable(viewModel).selectedTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .frame(height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: NihoppoRadius.medium, style: .continuous))
                                .background(
                                    RoundedRectangle(cornerRadius: NihoppoRadius.medium, style: .continuous)
                                        .fill(Color.nihoppoPeach.opacity(0.35))
                                )
                            }
                        }

                        Button {
                            viewModel.save()
                            savedSummary = viewModel.summary
                        } label: {
                            Label("Save My Routine", systemImage: "checkmark.circle.fill")
                        }
                        .buttonStyle(NihoppoPrimaryButtonStyle())

                        .padding(.top, NihoppoSpacing.s)
                    }
                    .padding(NihoppoSpacing.m)
                }
            } else {
                Color.clear.onAppear {
                    viewModel = CommitmentSetupViewModel(modelContext: modelContext)
                }
            }
        }
        .navigationDestination(item: $savedSummary) { summary in
            StudyPlanView(quizResult: quizResult, summary: summary)
        }
        .navigationTitle("Your Routine")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#Preview {
    NavigationStack {
        CommitmentSetupView(quizResult: QuizResult(score: 4, totalQuestions: 6, achievedLevel: .beginner, weakAreas: [.grammar]))
    }
}
