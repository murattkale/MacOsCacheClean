import SwiftUI

struct InfoCard3D: View {
    @State private var cardRotation: (x: Double, y: Double) = (0, 0)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Bilgi")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                InfoRow(icon: "shield.checkered", text: "Bu uygulama sistem cache'lerini temizler")
                InfoRow(icon: "lock.shield", text: "Önemli dosyalar korunur")
                InfoRow(icon: "exclamationmark.triangle", text: "İşlem geri alınamaz, dikkatli kullanın")
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.cyan.opacity(0.1))
                        .blur(radius: 20)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.cyan.opacity(0.2),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
        .shadow(color: .cyan.opacity(0.2), radius: 30, x: 0, y: 0)
        .rotation3DEffect(
            .degrees(cardRotation.x),
            axis: (x: 1, y: 0, z: 0),
            perspective: 0.2
        )
        .rotation3DEffect(
            .degrees(cardRotation.y),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.2
        )
        .onContinuousHover { phase in
            switch phase {
            case .active(let location):
                let centerX: CGFloat = 350
                let centerY: CGFloat = 300
                let deltaX = (location.x - centerX) / centerX
                let deltaY = (location.y - centerY) / centerY
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    cardRotation.y = Double(deltaX * 8)
                    cardRotation.x = Double(-deltaY * 8)
                }
            case .ended:
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    cardRotation = (0, 0)
                }
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.cyan.opacity(0.8))
                .frame(width: 16)
            
            Text(text)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.85))
        }
    }
}

