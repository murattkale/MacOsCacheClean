import SwiftUI

struct ContentView: View {
    @StateObject private var cacheService = CacheCleanerService()
    @State private var selectedCacheType: CacheType = .all
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var mouseLocation: CGPoint = .zero
    @State private var rotationAngle: Double = 0
    @State private var cardRotation: (x: Double, y: Double) = (0, 0)
    @State private var isHovering = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var glowIntensity: Double = 0.5
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground()
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let leftWidth = width * 0.38
                let rightWidth = width * 0.62
                
                HStack(alignment: .top, spacing: 24) {
                    VStack(spacing: 18) {
                        GlassPanel {
                            TitleCard3D(
                                rotationAngle: $rotationAngle,
                                mouseLocation: $mouseLocation
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(height: height * 0.22)
                        
                        GlassPanel {
                            CacheSelectionCard3D(
                                selectedCacheType: $selectedCacheType,
                                cardRotation: $cardRotation,
                                mouseLocation: $mouseLocation,
                                cacheService: cacheService
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(height: height * 0.42)
                        
                        GlassPanel {
                            CleanButton3D(
                                cacheService: cacheService,
                                buttonScale: $buttonScale,
                                isHovering: $isHovering,
                                action: startCleaning
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(height: height * 0.16)
                        
                        GlassPanel {
                            FooterLinkView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        }
                        .frame(height: height * 0.18)
                        
                        Spacer(minLength: 0)
                    }
                    .frame(width: leftWidth, alignment: .top)
                    
                    VStack(spacing: 18) {
                        GlassPanel {
                            StatusGlanceCard(cacheService: cacheService)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                        .frame(height: height * 0.22)
                        
                        GlassPanel {
                            Group {
                                if !cacheService.analysisResults.isEmpty && !cacheService.isCleaning {
                                    AnalysisCard3D(
                                        cacheService: cacheService,
                                        glowIntensity: $glowIntensity,
                                        onReanalyze: startAnalysis
                                    )
                                    .transition(.scale.combined(with: .opacity))
                                } else if cacheService.isAnalyzing {
                                    AnalysisProgressCard3D(
                                        cacheService: cacheService,
                                        glowIntensity: $glowIntensity
                                    )
                                    .transition(.scale.combined(with: .opacity))
                                } else {
                                    AnalysisPlaceholderCard()
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(height: height * 0.36)
                        
                        HStack(spacing: 18) {
                            GlassPanel {
                                Group {
                                    if cacheService.isCleaning {
                                        ProgressCard3D(
                                            cacheService: cacheService,
                                            glowIntensity: $glowIntensity
                                        )
                                        .transition(.scale.combined(with: .opacity))
                                    } else {
                                        CleaningPlaceholderCard()
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(width: rightWidth * 0.45, height: height * 0.28)
                            
                            GlassPanel {
                                InfoCard3D()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            }
                            .frame(width: rightWidth * 0.45, height: height * 0.28)
                        }
                    }
                    .frame(width: rightWidth, alignment: .top)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 28)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .frame(minWidth: 1024, minHeight: 640)
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        mouseLocation = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
            }
        )
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onContinuousHover { phase in
                        switch phase {
                        case .active(let location):
                            mouseLocation = location
                            updateCardRotations(location: location)
                        case .ended:
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                cardRotation = (0, 0)
                            }
                        }
                    }
            }
        )
        .onAppear {
            startRotationAnimation()
            startGlowAnimation()
            
            // İzin kontrolü
            print("🔐 İzin kontrolü yapılıyor...")
            PermissionManager.shared.requestPermissionsIfNeeded()
            
            // Uygulama açıldığında otomatik analiz başlat
            print("🚀 Uygulama açıldı, analiz başlatılıyor...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // İzin kontrolü sonrası analiz başlat
                if PermissionManager.shared.hasRequiredPermissions() {
                    startAnalysis()
                } else {
                    print("⚠️ Gerekli izinler yok, analiz başlatılamıyor")
                }
            }
        }
        .onChange(of: selectedCacheType) { _ in
            // Cache türü değiştiğinde otomatik analiz başlat
            startAnalysis()
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func updateCardRotations(location: CGPoint) {
        let centerX: CGFloat = 390
        let centerY: CGFloat = 280
        
        let deltaX = (location.x - centerX) / centerX
        let deltaY = (location.y - centerY) / centerY
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            cardRotation.y = Double(deltaX * 10)
            cardRotation.x = Double(-deltaY * 10)
        }
    }
    
    private func startRotationAnimation() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
    
    private func startGlowAnimation() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            glowIntensity = 1.0
        }
    }
    
    private func startAnalysis() {
        print("▶️ startAnalysis çağrıldı")
        print("   - isAnalyzing: \(cacheService.isAnalyzing)")
        print("   - isCleaning: \(cacheService.isCleaning)")
        print("   - selectedCacheType: \(cacheService.getCacheTypeName(selectedCacheType))")
        
        // Eğer zaten analiz yapılıyorsa veya temizleme yapılıyorsa, yeni analiz başlatma
        guard !cacheService.isAnalyzing && !cacheService.isCleaning else {
            print("⚠️ Analiz veya temizleme devam ediyor, yeni analiz başlatılmıyor")
            return
        }
        
        print("✅ Analiz başlatılıyor...")
        
        // Analiz başlat
        cacheService.analyzeCache(type: selectedCacheType) { [weak cacheService] results in
            print("📋 Analiz tamamlandı, \(results.count) sonuç döndü")
            guard cacheService != nil else {
                print("❌ CacheService nil oldu")
                return
            }
            print("✅ Analiz sonuçları güncellendi")
            // Analiz tamamlandı, buton artık aktif olacak
        }
    }
    
    private func startCleaning() {
        // Analiz tamamlanmamışsa önce analiz yap
        if cacheService.analysisResults.isEmpty && !cacheService.isAnalyzing {
            startAnalysis()
            return
        }
        
        // Analiz yapılıyorsa bekle
        if cacheService.isAnalyzing {
            return
        }
        
        // Analiz tamamlandıysa direkt temizleme başlat (onay almadan)
        cacheService.cleanCache(type: selectedCacheType) { result in
            switch result {
            case .success(let size):
                alertTitle = "Başarılı"
                alertMessage = "Cache temizleme tamamlandı!\nTemizlenen toplam boyut: \(cacheService.formatBytes(size))"
                showAlert = true
                // Temizleme tamamlandıktan sonra analiz sonuçlarını temizle ve yeniden analiz yap
                cacheService.analysisResults = []
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    startAnalysis()
                }
            case .failure(let error):
                alertTitle = "Hata"
                alertMessage = "Cache temizleme sırasında bir hata oluştu:\n\(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}

struct AnalysisPlaceholderCard: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
            Text("Analiz sonuçları burada hazır olacak.")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
            Text("Analiz tamamlandığında detaylar otomatik dolacak.")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
    }
}

struct CleaningPlaceholderCard: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
            Text("Temizleme başladığında ilerleme burada izlenir.")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
            Text("Şu an beklemede.")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
    }
}

struct GlassPanel<Content: View>: View {
    private let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.08),
                        Color.white.opacity(0.02)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.05))
                    .blur(radius: 30)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color.cyan.opacity(0.35),
                                Color.purple.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 12)
            .overlay(
                content()
                    .padding(16)
            )
    }
}

struct StatusGlanceCard: View {
    @ObservedObject var cacheService: CacheCleanerService
    
    private var totalSize: Int64 {
        cacheService.analysisResults.reduce(0) { $0 + $1.totalSize }
    }
    
    private var analyzedTypes: Int {
        cacheService.analysisResults.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Durum Özeti")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Capsule()
                    .fill(cacheService.isAnalyzing ? Color.orange.opacity(0.25) : Color.green.opacity(0.25))
                    .overlay(
                        Text(cacheService.isAnalyzing ? "Analiz Ediliyor" : "Hazır")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.horizontal, 8)
                    )
                    .frame(height: 22)
            }
            
            HStack(spacing: 12) {
                MetricBadge(
                    title: "Toplam Boyut",
                    value: cacheService.analysisResults.isEmpty ? "Bekleniyor" : cacheService.formatBytes(totalSize),
                    icon: "internaldrive"
                )
                
                MetricBadge(
                    title: "Analiz Edilen",
                    value: cacheService.analysisResults.isEmpty ? "0" : "\(analyzedTypes) tür",
                    icon: "list.bullet.rectangle"
                )
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            HStack(spacing: 8) {
                StatusTag(
                    icon: "bolt.fill",
                    text: cacheService.isCleaning ? "Temizleme aktif" : "Temizleme bekliyor",
                    active: cacheService.isCleaning
                )
                StatusTag(
                    icon: "shield.lefthalf.fill",
                    text: PermissionManager.shared.hasRequiredPermissions() ? "İzinler hazır" : "İzin gerekli",
                    active: PermissionManager.shared.hasRequiredPermissions()
                )
            }
        }
    }
}

struct MetricBadge: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.75))
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .cyan.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct StatusTag: View {
    let icon: String
    let text: String
    let active: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.system(size: 10, weight: .semibold))
        .foregroundColor(.white.opacity(active ? 0.85 : 0.55))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(active ? Color.white.opacity(0.12) : Color.white.opacity(0.05))
        )
        .overlay(
            Capsule()
                .stroke(active ? Color.white.opacity(0.2) : Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    ContentView()
}
