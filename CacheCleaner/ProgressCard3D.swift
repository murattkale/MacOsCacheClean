import SwiftUI

struct ProgressCard3D: View {
    @ObservedObject var cacheService: CacheCleanerService
    @Binding var glowIntensity: Double
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(cacheService.progress * 360))
                
                Text("Temizleme İlerlemesi")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(cacheService.progress * 100))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            // 3D Progress Bar
            ZStack(alignment: .leading) {
                // Arka plan
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                
                // Progress fill
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.blue,
                                        Color.purple,
                                        Color.pink
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * cacheService.progress, height: 24)
                            .shadow(color: .blue.opacity(glowIntensity * 0.8), radius: 12, x: 0, y: 0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.4),
                                                Color.white.opacity(0.1),
                                                Color.clear
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.5),
                                                Color.white.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .rotation3DEffect(
                                .degrees(5),
                                axis: (x: 1, y: 0, z: 0),
                                perspective: 0.3
                            )
                        
                        // Yüzde yazısı
                        if cacheService.progress > 0.1 {
                            Text("\(Int(cacheService.progress * 100))%")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 3)
                                .padding(.leading, 8)
                        }
                    }
                }
                .frame(height: 24)
            }
            .frame(height: 24)
            
            Text(cacheService.currentTask)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.3), radius: 4)
            
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
                
                Text("Temizlenen: \(cacheService.formatBytes(cacheService.cleanedSize))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.green.opacity(0.15),
                            Color.blue.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.green.opacity(0.1))
                        .blur(radius: 30)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.green.opacity(0.5),
                            Color.blue.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .green.opacity(glowIntensity * 0.5), radius: 25, x: 0, y: 0)
        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
        .scaleEffect(1.0 + (glowIntensity - 0.5) * 0.05)
        .rotation3DEffect(
            .degrees(3),
            axis: (x: 1, y: 0, z: 0),
            perspective: 0.2
        )
        .rotation3DEffect(
            .degrees(2),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.2
        )
    }
}

