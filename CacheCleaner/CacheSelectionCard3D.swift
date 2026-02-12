import SwiftUI

struct CacheSelectionCard3D: View {
    @Binding var selectedCacheType: CacheType
    @Binding var cardRotation: (x: Double, y: Double)
    @Binding var mouseLocation: CGPoint
    @ObservedObject var cacheService: CacheCleanerService
    
    private let cacheTypes: [(type: CacheType, icon: String, title: String)] = [
        (.all, "sparkles", "Tümü"),
        (.userCache, "person.fill", "Kullanıcı"),
        (.systemCache, "gearshape.fill", "Sistem"),
        (.browserCache, "safari", "Tarayıcı"),
        (.logs, "doc.text.fill", "Loglar"),
        (.trash, "trash.fill", "Çöp"),
        (.derivedData, "hammer.fill", "Xcode")
    ]
    
    private func sizeForType(_ type: CacheType) -> Int64 {
        if type == .all {
            return cacheService.analysisResults.reduce(0) { $0 + $1.totalSize }
        }
        return cacheService.analysisResults.first(where: { $0.type == type })?.totalSize ?? 0
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [.cyan, .purple], startPoint: .leading, endPoint: .trailing))
                Text("Cache Türü Seçin")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                
                if cacheService.isAnalyzing {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.4)
                            .tint(.white)
                        Text("Analiz ediliyor...")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(cacheTypes, id: \.type) { item in
                    CacheTypeButton(
                        type: item.type,
                        icon: item.icon,
                        title: item.title,
                        size: sizeForType(item.type),
                        isSelected: selectedCacheType == item.type,
                        isLoading: cacheService.isAnalyzing && cacheService.analysisResults.isEmpty,
                        cacheService: cacheService
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCacheType = item.type
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.12), Color.white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.blue.opacity(0.1))
                        .blur(radius: 20)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.4), Color.blue.opacity(0.3), Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
        .shadow(color: .blue.opacity(0.2), radius: 30, x: 0, y: 0)
        .rotation3DEffect(.degrees(cardRotation.x * 0.3), axis: (x: 1, y: 0, z: 0), perspective: 0.1)
        .rotation3DEffect(.degrees(cardRotation.y * 0.3), axis: (x: 0, y: 1, z: 0), perspective: 0.1)
    }
}

struct CacheTypeButton: View {
    let type: CacheType
    let icon: String
    let title: String
    let size: Int64
    let isSelected: Bool
    let isLoading: Bool
    @ObservedObject var cacheService: CacheCleanerService
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(LinearGradient(colors: [.blue.opacity(0.4), .purple.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 50, height: 50)
                            .blur(radius: 10)
                    }
                    
                    Circle()
                        .fill(
                            isSelected ?
                            LinearGradient(colors: [.blue.opacity(0.9), .purple.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [Color.white.opacity(0.18), Color.white.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: isSelected ? .blue.opacity(0.5) : .clear, radius: 10)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                }
                
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .semibold))
                    .foregroundColor(.white.opacity(isSelected ? 1 : 0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                if isLoading && size == 0 {
                    Text("Analiz...")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.white.opacity(0.08)))
                } else {
                    Text(size > 0 ? cacheService.formatBytes(size) : "0 KB")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: isSelected ? [.cyan, .blue] : [.orange.opacity(0.8), .yellow.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(
                                    isSelected ?
                                    Color.white.opacity(0.15) :
                                    Color.white.opacity(0.08)
                                )
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isSelected ?
                        LinearGradient(colors: [.blue.opacity(0.25), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ?
                        LinearGradient(colors: [.blue.opacity(0.7), .purple.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [Color.white.opacity(0.25), Color.white.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: isSelected ? .blue.opacity(0.35) : .black.opacity(0.15), radius: isSelected ? 12 : 6, x: 0, y: isSelected ? 6 : 3)
            .scaleEffect(isHovering ? 1.08 : 1.0)
            .rotation3DEffect(.degrees(isHovering ? 3 : 0), axis: (x: 1, y: 0, z: 0), perspective: 0.3)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isHovering = hovering
            }
        }
    }
}
