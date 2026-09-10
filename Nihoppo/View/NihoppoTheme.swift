//
//  NihoppoTheme.swift
//  Nihoppo
//
//  Created by Elena Angkawi on 09/09/26.
//
//
//  NihoppoTheme.swift
//  Nihoppo
//
//  Shared design system: colors, spacing, corner radius, shadows,
//  button styles, and small brand decorations.
//
//  Colors are matched to the Nihoppo logo (denim blue, vermillion red,
//  cream background, shiba/fox mascot).
//

import SwiftUI

// MARK: - Colors

extension Color {
    /// Primary brand blue — the denim/indigo blue from the Nihoppo logo circle & wordmark.
    static let nihoppoBlue = Color(
        light: UIColor(red: 0.29, green: 0.44, blue: 0.63, alpha: 1),
        dark: UIColor(red: 0.47, green: 0.62, blue: 0.82, alpha: 1)
    )

    /// Deeper ink blue — used for primary text and high-emphasis surfaces.
    static let nihoppoInk = Color(
        light: UIColor(red: 0.15, green: 0.22, blue: 0.30, alpha: 1),
        dark: UIColor(red: 0.90, green: 0.93, blue: 0.97, alpha: 1)
    )

    /// Accent vermillion red — torii-gate red from the logo. Used sparingly.
    static let nihoppoRed = Color(
        light: UIColor(red: 0.88, green: 0.29, blue: 0.26, alpha: 1),
        dark: UIColor(red: 0.92, green: 0.42, blue: 0.38, alpha: 1)
    )

    /// Warm cream background.
    static let nihoppoCream = Color(
        light: UIColor(red: 0.97, green: 0.95, blue: 0.91, alpha: 1),
        dark: UIColor(red: 0.09, green: 0.11, blue: 0.15, alpha: 1)
    )

    /// Card surface — slightly lifted off the cream background.
    static let nihoppoCard = Color(
        light: UIColor.white,
        dark: UIColor(red: 0.14, green: 0.17, blue: 0.22, alpha: 1)
    )

    /// Muted secondary text.
    static let nihoppoSecondaryText = Color(
        light: UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1),
        dark: UIColor(red: 0.68, green: 0.68, blue: 0.70, alpha: 1)
    )

    /// Soft hairline border for cards.
    static let nihoppoBorder = Color(
        light: UIColor(red: 0.87, green: 0.84, blue: 0.77, alpha: 1),
        dark: UIColor(red: 0.24, green: 0.27, blue: 0.32, alpha: 1)
    )

    // Supporting pastels, rotated across activity cards / feedback states.
    static let nihoppoMint = Color(
        light: UIColor(red: 0.75, green: 0.89, blue: 0.82, alpha: 1),
        dark: UIColor(red: 0.20, green: 0.34, blue: 0.28, alpha: 1)
    )
    static let nihoppoSky = Color(
        light: UIColor(red: 0.79, green: 0.88, blue: 0.95, alpha: 1),
        dark: UIColor(red: 0.18, green: 0.28, blue: 0.38, alpha: 1)
    )
    static let nihoppoPeach = Color(
        light: UIColor(red: 0.99, green: 0.85, blue: 0.72, alpha: 1),
        dark: UIColor(red: 0.38, green: 0.28, blue: 0.18, alpha: 1)
    )
    static let nihoppoLavender = Color(
        light: UIColor(red: 0.86, green: 0.82, blue: 0.94, alpha: 1),
        dark: UIColor(red: 0.28, green: 0.24, blue: 0.38, alpha: 1)
    )
    static let nihoppoSunflower = Color(
        light: UIColor(red: 0.99, green: 0.91, blue: 0.66, alpha: 1),
        dark: UIColor(red: 0.40, green: 0.34, blue: 0.16, alpha: 1)
    )

    /// Rotating pastel palette, useful for cycling accent colors across a list.
    static let nihoppoPastels: [Color] = [.nihoppoSky, .nihoppoPeach, .nihoppoMint, .nihoppoLavender, .nihoppoSunflower]

    /// Convenience initializer for a color that adapts to light/dark mode.
    init(light: UIColor, dark: UIColor) {
        self.init(UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        })
    }
}

enum NihoppoSpacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 44
}

enum NihoppoRadius {
    static let small: CGFloat = 10
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let pill: CGFloat = 999
}



extension View {
    func nihoppoShadow(strong: Bool = false) -> some View {
        self.shadow(
            color: Color.black.opacity(strong ? 0.14 : 0.07),
            radius: strong ? 14 : 8,
            x: 0,
            y: strong ? 8 : 4
        )
    }
}



struct NihoppoCard<Content: View>: View {
    var padding: CGFloat = NihoppoSpacing.m
    var cornerRadius: CGFloat = NihoppoRadius.large
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.nihoppoCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.nihoppoBorder, lineWidth: 1)
            )
            .nihoppoShadow()
    }
}

struct NihoppoPrimaryButtonStyle: ButtonStyle {
    var tint: Color = .nihoppoBlue
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, NihoppoSpacing.m)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: NihoppoRadius.medium, style: .continuous)
                    .fill(isDisabled ? tint.opacity(0.4) : tint)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .nihoppoShadow(strong: true)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct NihoppoSecondaryButtonStyle: ButtonStyle {
    var tint: Color = .nihoppoBlue

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(tint)
            .padding(.vertical, NihoppoSpacing.m)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: NihoppoRadius.medium, style: .continuous)
                    .fill(tint.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: NihoppoRadius.medium, style: .continuous)
                    .strokeBorder(tint.opacity(0.35), lineWidth: 1.25)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct NihoppoProgressBar: View {
    var progress: Double
    var tint: Color = .nihoppoBlue

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(tint.opacity(0.15))
                Capsule()
                    .fill(tint)
                    .frame(width: max(10, geo.size.width * min(max(progress, 0), 1)))
                    .animation(.easeInOut(duration: 0.35), value: progress)
            }
        }
        .frame(height: 10)
    }
}


struct FoxMascotView: View {
    enum Expression {
        case content   // closed happy eyes (default / home)
        case celebrating // same face, used with confetti/sparkles around it
        case thinking  // slightly tilted, used for loading states
    }

    var expression: Expression = .content
    var size: CGFloat = 96

    var body: some View {
        ZStack {
            // Ears
            HStack(spacing: size * 0.34) {
                Triangle().fill(Color.nihoppoRed)
                    .frame(width: size * 0.28, height: size * 0.30)
                    .rotationEffect(.degrees(-8))
                Triangle().fill(Color.nihoppoRed)
                    .frame(width: size * 0.28, height: size * 0.30)
                    .rotationEffect(.degrees(8))
            }
            .offset(y: -size * 0.42)

            // Head
            Circle()
                .fill(Color.nihoppoRed)
                .frame(width: size, height: size)

            // Muzzle
            Ellipse()
                .fill(Color.white)
                .frame(width: size * 0.62, height: size * 0.48)
                .offset(y: size * 0.16)

            // Eyes (closed, friendly)
            HStack(spacing: size * 0.22) {
                Capsule().fill(Color.nihoppoInk)
                    .frame(width: size * 0.16, height: size * 0.035)
                Capsule().fill(Color.nihoppoInk)
                    .frame(width: size * 0.16, height: size * 0.035)
            }
            .offset(y: -size * 0.02)

            // Nose
            Circle()
                .fill(Color.nihoppoInk)
                .frame(width: size * 0.09, height: size * 0.09)
                .offset(y: size * 0.10)
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(expression == .thinking ? -6 : 0))
        .animation(.easeInOut(duration: 0.4), value: expression)
        .accessibilityHidden(true)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// Decorative silhouettes

struct ToriiSilhouette: View {
    var tint: Color = .nihoppoRed
    var size: CGFloat = 64

    var body: some View {
        VStack(spacing: size * 0.08) {
            RoundedRectangle(cornerRadius: 2)
                .fill(tint)
                .frame(width: size * 1.15, height: size * 0.12)
            RoundedRectangle(cornerRadius: 2)
                .fill(tint)
                .frame(width: size * 0.95, height: size * 0.09)
            HStack(spacing: size * 0.62) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(tint)
                    .frame(width: size * 0.10, height: size * 0.62)
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(tint)
                    .frame(width: size * 0.10, height: size * 0.62)
            }
        }
        .accessibilityHidden(true)
    }
}

/// A minimal Mount Fuji silhouette with a snow cap.
struct FujiSilhouette: View {
    var tint: Color = .nihoppoBlue
    var size: CGFloat = 64

    var body: some View {
        ZStack(alignment: .top) {
            Triangle()
                .fill(tint.opacity(0.35))
                .frame(width: size, height: size * 0.62)
            Triangle()
                .fill(tint.opacity(0.6))
                .frame(width: size * 0.32, height: size * 0.18)
                .offset(y: -2)
        }
        .accessibilityHidden(true)
    }
}

/// A tiny sakura petal, used as a sparse decorative accent.
struct SakuraPetal: View {
    var tint: Color = .nihoppoRed
    var size: CGFloat = 14

    var body: some View {
        Image(systemName: "seal.fill")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(tint.opacity(0.35))
            .accessibilityHidden(true)
    }
}
