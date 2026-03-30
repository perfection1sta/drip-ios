import CoreGraphics

// MARK: - Spacing Tokens
// 4-point grid system used across all layouts.

enum Spacing {
    static let xxs:  CGFloat = 4
    static let xs:   CGFloat = 8
    static let sm:   CGFloat = 12
    static let md:   CGFloat = 16
    static let lg:   CGFloat = 20
    static let xl:   CGFloat = 24
    static let xxl:  CGFloat = 32
    static let xxxl: CGFloat = 48
    static let huge: CGFloat = 64

    enum Radius {
        static let sm:   CGFloat = 8
        static let md:   CGFloat = 12
        static let lg:   CGFloat = 16
        static let xl:   CGFloat = 20
        static let xxl:  CGFloat = 28
        static let pill: CGFloat = 999
    }

    enum Shadow {
        static let card = (color: 0.0, opacity: 0.40, radius: 24.0, x: 0.0, y: 8.0)
        static let glow = (color: 0.0, opacity: 0.25, radius: 32.0, x: 0.0, y: 4.0)
    }
}
