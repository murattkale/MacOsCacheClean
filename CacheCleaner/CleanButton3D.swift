import SwiftUI

struct CleanButton3D: View {
    @ObservedObject var cacheService: CacheCleanerService
    @Binding var buttonScale: CGFloat
    @Binding var isHovering: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if cacheService.isCleaning || cacheService.isAnalyzing {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.2)
                        .tint(.white)
                } else {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 20, weight: .bold))
                        .rotationEffect(.degrees(isHovering ? 15 : 0))
                }
                
                Text(
                    cacheService.isAnalyzing ? "Analiz Ediliyor..." :
                    cacheService.isCleaning ? "Temizleniyor..." :
                    cacheService.analysisResults.isEmpty ? "Analiz Bekleniyor..." :
                    "Cache'leri Temizle"
                )
                .font(.system(size: 15, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                Group {
                    if cacheService.isCleaning || cacheService.isAnalyzing {
                        LinearGradient(
                            colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else if cacheService.analysisResults.isEmpty {
                        LinearGradient(
                            colors: [Color.orange.opacity(0.6), Color.orange.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        LinearGradient(
                            colors: [
                                Color.blue,
                                Color.purple,
                                Color.pink
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
            )
            .foregroundColor(.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            )
            .shadow(
                color: (cacheService.isCleaning || cacheService.isAnalyzing) ? .gray.opacity(0.3) :
                       cacheService.analysisResults.isEmpty ? .orange.opacity(0.4) :
                       .blue.opacity(0.6),
                radius: isHovering ? 30 : 20,
                x: 0,
                y: isHovering ? 15 : 10
            )
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(buttonScale)
        .rotation3DEffect(
            .degrees(isHovering ? 5 : 0),
            axis: (x: 1, y: 0, z: 0),
            perspective: 0.3
        )
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isHovering = hovering
                buttonScale = hovering ? 1.05 : 1.0
            }
        }
        .disabled(cacheService.isCleaning || cacheService.isAnalyzing || cacheService.analysisResults.isEmpty)
    }
}

