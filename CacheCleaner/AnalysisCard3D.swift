import SwiftUI
import AppKit

struct AnalysisCard3D: View {
    @ObservedObject var cacheService: CacheCleanerService
    @Binding var glowIntensity: Double
    let onReanalyze: () -> Void
    @State private var isHoveringReanalyze = false
    

    var totalSize: Int64 {
        
        cacheService.analysisResults.reduce(0) { $0 + $1.totalSize }
    }
    
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
                
                Text("Analiz Sonuçları")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Toplam: \(cacheService.formatBytes(totalSize))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            // Analiz sonuçları listesi - Genişletilebilir
            VStack(spacing: 6) {
                ForEach(cacheService.analysisResults, id: \.type) { result in
                    if result.totalSize > 0 {
                        ExpandableAnalysisRow(result: result, cacheService: cacheService)
                    }
                }
            }
            
            // Tekrar Analiz Et Butonu
            Button(action: {
                onReanalyze()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .semibold))
                    
                    Text("Tekrar Analiz Et")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.orange.opacity(0.7),
                                    Color.yellow.opacity(0.6)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .orange.opacity(isHoveringReanalyze ? 0.5 : 0.3), radius: isHoveringReanalyze ? 10 : 6, x: 0, y: isHoveringReanalyze ? 4 : 2)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(cacheService.isAnalyzing || cacheService.isCleaning)
            .opacity(cacheService.isAnalyzing || cacheService.isCleaning ? 0.6 : 1.0)
            .onHover { hovering in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isHoveringReanalyze = hovering
                }
            }
            .scaleEffect(isHoveringReanalyze ? 1.02 : 1.0)
            .rotation3DEffect(
                .degrees(isHoveringReanalyze ? 2 : 0),
                axis: (x: 1, y: 0, z: 0),
                perspective: 0.2
            )
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
            .degrees(2),
            axis: (x: 1, y: 0, z: 0),
            perspective: 0.1
        )
    }
}

struct ExpandableAnalysisRow: View {
    let result: CacheAnalysisResult
    let cacheService: CacheCleanerService
    @State private var isExpanded = false
    
    var typeName: String {
        switch result.type {
        case .userCache: return "Kullanıcı Cache"
        case .systemCache: return "Sistem Cache"
        case .browserCache: return "Tarayıcı Cache"
        case .logs: return "Log Dosyaları"
        case .trash: return "Çöp Kutusu"
        case .derivedData: return "Xcode Derived"
        case .all: return "Tümü"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Ana satır - tıklanabilir
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.orange.opacity(0.8))
                        .frame(width: 12)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.6), .yellow.opacity(0.4)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 6, height: 6)
                    
                    Text(typeName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Text("\(result.itemCount) öğe")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(cacheService.formatBytes(result.totalSize))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(isExpanded ? 0.1 : 0.05))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Genişletilmiş içerik - Cache dosyaları listesi
            if isExpanded {
                VStack(spacing: 4) {
                    ForEach(result.items, id: \.path) { item in
                        CacheFileRow(item: item, cacheService: cacheService)
                    }
                }
                .padding(.leading, 20)
                .padding(.top, 4)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
        }
    }
}

struct CacheFileRow: View {
    let item: CacheItem
    let cacheService: CacheCleanerService
    @State private var isHovering = false
    
    private var isDirectory: Bool {
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: item.path, isDirectory: &isDir)
        return isDir.boolValue
    }
    
    var body: some View {
        Button(action: {
            // Finder'da aç
            let fileManager = FileManager.default
            var isDir: ObjCBool = false
            
            if fileManager.fileExists(atPath: item.path, isDirectory: &isDir) {
                if isDir.boolValue {
                    // Klasör ise direkt aç
                    NSWorkspace.shared.open(URL(fileURLWithPath: item.path))
                } else {
                    // Dosya ise parent klasörü aç ve dosyayı seç
                    let parentPath = (item.path as NSString).deletingLastPathComponent
                    NSWorkspace.shared.selectFile(item.path, inFileViewerRootedAtPath: parentPath)
                }
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: isDirectory ? "folder.fill" : "doc.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.orange.opacity(0.7))
                    .frame(width: 16)
                
                Text(item.name)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Spacer()
                
                Text(cacheService.formatBytes(item.size))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.orange.opacity(isHovering ? 1.0 : 0.6))
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(isHovering ? 0.1 : 0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}

