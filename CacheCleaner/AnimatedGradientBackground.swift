import SwiftUI

struct AnimatedGradientBackground: View {
    @State private var gradientOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.15, green: 0.15, blue: 0.3),
                    Color(red: 0.2, green: 0.1, blue: 0.25)
                ],
                startPoint: UnitPoint(x: 0 + gradientOffset, y: 0),
                endPoint: UnitPoint(x: 1 + gradientOffset, y: 1)
            )
            
            // Animated overlay
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.15),
                    Color.pink.opacity(0.1)
                ],
                startPoint: UnitPoint(x: 0.5 - gradientOffset * 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5 + gradientOffset * 0.5, y: 1)
            )
            .blur(radius: 100)
        }
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: true)) {
                gradientOffset = 0.3
            }
        }
    }
}

