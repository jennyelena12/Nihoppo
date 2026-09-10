//
//  HomeView.swift
//  Nihoppo
//
//  Created by Elena Angkawi on 04/09/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.nihoppoCream.ignoresSafeArea()

                // Subtle decorative silhouettes
                VStack {
                    Spacer()
                    HStack {
                        FujiSilhouette(size: 110)
                            .offset(x: -18, y: 26)
                        Spacer()
                        ToriiSilhouette(size: 70)
                            .offset(x: 18, y: 10)
                    }
                }
                .opacity(0.5)
                .ignoresSafeArea(edges: .bottom)

                ScrollView {
                    VStack(spacing: NihoppoSpacing.xl) {
                        Spacer(minLength: NihoppoSpacing.xl)

                        VStack(spacing: NihoppoSpacing.m) {
                            FoxMascotView(size: 108)

                            Text("nihoppo")
                                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.nihoppoBlue)

                            Text("Japanese Learning")
                                .font(.footnote.weight(.medium))
                                .tracking(2)
                                .textCase(.uppercase)
                                .foregroundStyle(Color.nihoppoSecondaryText)
                        }

                        VStack(spacing: NihoppoSpacing.s) {
                            Text("Konnichiwa! 👋")
                                .font(.system(.title2, design: .rounded, weight: .semibold))
                                .foregroundStyle(Color.nihoppoInk)

                            Text("Nihoppo builds you a personalized Japanese study plan — take a quick placement quiz and we'll take it from there.")
                                .font(.body)
                                .foregroundStyle(Color.nihoppoSecondaryText)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, NihoppoSpacing.m)
                        }

                        HighlightRow()
                            .padding(.horizontal, NihoppoSpacing.m)

                        Spacer(minLength: NihoppoSpacing.l)

                        VStack(spacing: NihoppoSpacing.s) {
                            NavigationLink {
                                QuizView(questions: QuestionSeedData.all)
                            } label: {
                                Label("Take Placement Quiz", systemImage: "arrow.right.circle.fill")
                            }
                            .buttonStyle(NihoppoPrimaryButtonStyle())

                            Text("Takes about 2 minutes")
                                .font(.caption)
                                .foregroundStyle(Color.nihoppoSecondaryText)
                        }
                        .padding(.horizontal, NihoppoSpacing.l)

                        Spacer(minLength: NihoppoSpacing.xl)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

private struct HighlightRow: View {
    private let items: [(icon: String, title: String, color: Color)] = [
        ("target", "Placement quiz", .nihoppoSky),
        ("calendar.badge.clock", "Daily routine", .nihoppoPeach),
        ("sparkles", "AI study plan", .nihoppoMint)
    ]

    var body: some View {
        HStack(spacing: NihoppoSpacing.s) {
            ForEach(items, id: \.title) { item in
                VStack(spacing: NihoppoSpacing.xs) {
                    ZStack {
                        Circle()
                            .fill(item.color)
                            .frame(width: 44, height: 44)
                        Image(systemName: item.icon)
                            .foregroundStyle(Color.nihoppoInk)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    Text(item.title)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color.nihoppoSecondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    HomeView()
}
