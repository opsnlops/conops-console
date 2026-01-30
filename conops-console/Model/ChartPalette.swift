import SwiftUI

struct ChartPalette {
    private static let goldenRatio: Double = 0.61803398875
    private static let baseHue: Double = Double.random(in: 0...1)

    static func seriesColors(count: Int, saturation: Double = 0.62, brightness: Double = 0.9) -> [Color] {
        guard count > 0 else { return [] }
        var colors: [Color] = []
        colors.reserveCapacity(count)

        var hue = baseHue
        for _ in 0..<count {
            hue = (hue + goldenRatio).truncatingRemainder(dividingBy: 1.0)
            colors.append(Color(hue: hue, saturation: saturation, brightness: brightness))
        }

        return colors
    }
}
