import SwiftUI

struct AnalysisProgressCard3D: View {
    @ObservedObject var cacheService: CacheCleanerService
    @Binding var glowIntensity: Double
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(cacheService.progress * 360))
                
                Text("Analiz İlerlemesi")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(cacheService.progress * 100))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
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
                                        Color.orange,
                                        Color.yellow,
                                        Color.orange.opacity(0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * cacheService.progress, height: 24)
                            .shadow(color: .orange.opacity(glowIntensity * 0.8), radius: 12, x: 0, y: 0)
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
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.3), radius: 3)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.orange.opacity(0.15),
                            Color.yellow.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.orange.opacity(0.1))
                        .blur(radius: 20)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.orange.opacity(0.5),
                            Color.yellow.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .orange.opacity(glowIntensity * 0.4), radius: 20, x: 0, y: 0)
        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
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

