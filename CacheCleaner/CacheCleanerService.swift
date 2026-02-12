import Foundation
import AppKit

enum CacheType {
    case userCache
    case systemCache
    case browserCache
    case logs
    case trash
    case derivedData
    case all
}

struct CacheItem {
    let name: String
    let path: String
    let size: Int64
}

struct CacheAnalysisResult {
    let type: CacheType
    let totalSize: Int64
    let itemCount: Int
    let items: [CacheItem]
}

class CacheCleanerService: ObservableObject {
    @Published var isCleaning = false
    @Published var isAnalyzing = false
    @Published var progress: Double = 0.0
    @Published var currentTask: String = ""
    @Published var cleanedSize: Int64 = 0
    @Published var analysisResults: [CacheAnalysisResult] = []
    
    private let fileManager = FileManager.default
    
    func cleanCache(type: CacheType, completion: @escaping (Result<Int64, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isCleaning = true
                self.progress = 0.0
                self.cleanedSize = 0
            }
            
            var totalSize: Int64 = 0
            let cacheItems = self.getCacheItems(for: type)
            let totalItems = max(cacheItems.count, 1) // Sıfıra bölme hatasını önle
            
            if cacheItems.isEmpty {
                DispatchQueue.main.async {
                    self.progress = 1.0
                    self.currentTask = "Temizlenecek cache bulunamadı"
                    self.isCleaning = false
                    completion(.success(0))
                }
                return
            }
            
            // Toplam boyutu önceden hesapla (daha doğru progress için)
            var totalSizeToClean: Int64 = 0
            for item in cacheItems {
                totalSizeToClean += item.size
            }
            
            var cleanedSizeSoFar: Int64 = 0
            
            for (index, item) in cacheItems.enumerated() {
                DispatchQueue.main.async {
                    self.currentTask = "Temizleniyor: \(item.name)"
                    // Boyut bazlı progress hesapla
                    if totalSizeToClean > 0 {
                        self.progress = Double(cleanedSizeSoFar) / Double(totalSizeToClean)
                    } else {
                        self.progress = Double(index + 1) / Double(totalItems)
                    }
                }
                
                let size = self.deleteItem(at: item.path)
                totalSize += size
                cleanedSizeSoFar += size
                
                DispatchQueue.main.async {
                    self.cleanedSize = totalSize
                    // Güncel progress
                    if totalSizeToClean > 0 {
                        self.progress = Double(cleanedSizeSoFar) / Double(totalSizeToClean)
                    } else {
                        self.progress = Double(index + 1) / Double(totalItems)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.progress = 1.0
                self.currentTask = "Tamamlandı!"
                self.isCleaning = false
                completion(.success(totalSize))
            }
        }
    }
    
    private func getCacheItems(for type: CacheType) -> [CacheItem] {
        var items: [CacheItem] = []
        
        switch type {
        case .userCache:
            items.append(contentsOf: getUserCacheItems())
        case .systemCache:
            items.append(contentsOf: getSystemCacheItems())
        case .browserCache:
            items.append(contentsOf: getBrowserCacheItems())
        case .logs:
            items.append(contentsOf: getLogItems())
        case .trash:
            items.append(contentsOf: getTrashItems())
        case .derivedData:
            items.append(contentsOf: getDerivedDataItems())
        case .all:
            items.append(contentsOf: getUserCacheItems())
            items.append(contentsOf: getSystemCacheItems())
            items.append(contentsOf: getBrowserCacheItems())
            items.append(contentsOf: getLogItems())
            items.append(contentsOf: getTrashItems())
            items.append(contentsOf: getDerivedDataItems())
        }
        
        return items
    }
    
    private func getUserCacheItems() -> [CacheItem] {
        var items: [CacheItem] = []
        let homeDir = NSHomeDirectory()
        let cachePath = "\(homeDir)/Library/Caches"
        
        print("📂 Kullanıcı cache yolu: \(cachePath)")
        guard fileManager.fileExists(atPath: cachePath) else {
            print("❌ Cache klasörü bulunamadı: \(cachePath)")
            return items
        }
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: cachePath)
            print("📋 Klasör içeriği: \(contents.count) öğe")
            
            for item in contents {
                let fullPath = "\(cachePath)/\(item)"
                
                // .DS_Store gibi gizli dosyaları atla
                if item.hasPrefix(".") { continue }
                
                // Erişim kontrolü
                guard fileManager.isReadableFile(atPath: fullPath) else {
                    print("⚠️ Erişilemez: \(item)")
                    continue
                }
                
                // Boyut hesapla
                if let size = getDirectorySize(at: fullPath) {
                    print("✅ \(item): \(formatBytes(size))")
                    items.append(CacheItem(name: item, path: fullPath, size: size))
                } else {
                    print("⚠️ Boyut hesaplanamadı: \(item)")
                }
            }
        } catch {
            print("❌ Kullanıcı cache okuma hatası: \(error.localizedDescription)")
        }
        
        print("📊 Toplam bulunan: \(items.count) öğe")
        return items
    }
    
    private func getSystemCacheItems() -> [CacheItem] {
        var items: [CacheItem] = []
        let cachePath = "/Library/Caches"
        
        guard fileManager.fileExists(atPath: cachePath) else { return items }
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: cachePath)
            for item in contents {
                let fullPath = "\(cachePath)/\(item)"
                // Sistem cache'lerine erişim kısıtlı olabilir, hata yönetimi ile
                if fileManager.isReadableFile(atPath: fullPath) {
                    if let size = getDirectorySize(at: fullPath) {
                        items.append(CacheItem(name: item, path: fullPath, size: size))
                    }
                }
            }
        } catch {
            print("Sistem cache okuma hatası: \(error.localizedDescription)")
        }
        
        return items
    }
    
    private func getBrowserCacheItems() -> [CacheItem] {
        var items: [CacheItem] = []
        let homeDir = NSHomeDirectory()
        
        let browserPaths = [
            "\(homeDir)/Library/Caches/com.apple.Safari",
            "\(homeDir)/Library/Caches/com.google.Chrome",
            "\(homeDir)/Library/Caches/com.google.Chrome.helper",
            "\(homeDir)/Library/Caches/com.mozilla.firefox",
            "\(homeDir)/Library/Caches/com.operasoftware.Opera",
            "\(homeDir)/Library/Caches/com.microsoft.edgemac",
            "\(homeDir)/Library/Safari/LocalStorage",
            "\(homeDir)/Library/Application Support/Google/Chrome/Default/Cache",
            "\(homeDir)/Library/Application Support/Firefox/Profiles",
            "\(homeDir)/Library/Caches/com.brave.Browser",
            "\(homeDir)/Library/Caches/com.vivaldi.Vivaldi"
        ]
        
        for path in browserPaths {
            guard fileManager.fileExists(atPath: path) else { continue }
            guard fileManager.isReadableFile(atPath: path) else { continue }
            
            if let size = getDirectorySize(at: path) {
                let name = (path as NSString).lastPathComponent
                items.append(CacheItem(name: name, path: path, size: size))
            }
        }
        
        return items
    }
    
    private func getLogItems() -> [CacheItem] {
        var items: [CacheItem] = []
        let homeDir = NSHomeDirectory()
        let logPath = "\(homeDir)/Library/Logs"
        
        guard fileManager.fileExists(atPath: logPath) else { return items }
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: logPath)
            for item in contents {
                let fullPath = "\(logPath)/\(item)"
                guard fileManager.isReadableFile(atPath: fullPath) else { continue }
                
                if let size = getDirectorySize(at: fullPath) {
                    items.append(CacheItem(name: item, path: fullPath, size: size))
                }
            }
        } catch {
            print("Log okuma hatası: \(error.localizedDescription)")
        }
        
        return items
    }
    
    private func getTrashItems() -> [CacheItem] {
        var items: [CacheItem] = []
        let homeDir = NSHomeDirectory()
        let trashPath = "\(homeDir)/.Trash"
        
        guard fileManager.fileExists(atPath: trashPath) else {
            print("⚠️ Çöp kutusu klasörü bulunamadı: \(trashPath)")
            return items
        }
        
        // .Trash klasörüne erişim kontrolü (opsiyonel)
        // Erişim yoksa sessizce atla, hata verme
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: trashPath)
            print("📋 Çöp kutusu içeriği: \(contents.count) öğe")
            
            for item in contents {
                let fullPath = "\(trashPath)/\(item)"
                
                // Gizli dosyaları atla
                if item.hasPrefix(".") { continue }
                
                // Erişim kontrolü - erişilemezse atla
                guard fileManager.isReadableFile(atPath: fullPath) else {
                    continue
                }
                
                if let size = getDirectorySize(at: fullPath), size > 0 {
                    items.append(CacheItem(name: item, path: fullPath, size: size))
                }
            }
        } catch {
            // Çöp kutusuna erişim yoksa sessizce atla (normal bir durum)
            print("⚠️ Çöp kutusu okunamıyor (normal olabilir): \(error.localizedDescription)")
        }
        
        return items
    }
    
    private func getDerivedDataItems() -> [CacheItem] {
        var items: [CacheItem] = []
        let homeDir = NSHomeDirectory()
        let derivedDataPath = "\(homeDir)/Library/Developer/Xcode/DerivedData"
        
        guard fileManager.fileExists(atPath: derivedDataPath) else { return items }
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: derivedDataPath)
            for item in contents {
                let fullPath = "\(derivedDataPath)/\(item)"
                guard fileManager.isReadableFile(atPath: fullPath) else { continue }
                
                if let size = getDirectorySize(at: fullPath) {
                    items.append(CacheItem(name: item, path: fullPath, size: size))
                }
            }
        } catch {
            print("DerivedData okuma hatası: \(error.localizedDescription)")
        }
        
        return items
    }
    
    private func getDirectorySize(at path: String) -> Int64? {
        guard fileManager.fileExists(atPath: path) else {
            print("⚠️ getDirectorySize: Dosya/klasör yok: \(path)")
            return nil
        }
        
        var totalSize: Int64 = 0
        var isDirectory: ObjCBool = false
        
        guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory) else {
            print("⚠️ getDirectorySize: Dosya/klasör kontrolü başarısız: \(path)")
            return nil
        }
        
        if isDirectory.boolValue {
            // Klasör ise
            guard let enumerator = fileManager.enumerator(atPath: path) else {
                print("⚠️ getDirectorySize: Enumerator oluşturulamadı: \(path)")
                return nil
            }
            
            // Çok fazla dosya varsa takılmayı önlemek için limit
            var fileCount = 0
            var processedFiles = 0
            let maxFiles = 10000 // Maksimum dosya sayısı
            
            for file in enumerator {
                fileCount += 1
                if fileCount > maxFiles {
                    print("⚠️ getDirectorySize: Maksimum dosya sayısına ulaşıldı: \(path)")
                    break // Çok fazla dosya varsa durdur
                }
                
                if let filePath = file as? String {
                    let fullPath = (path as NSString).appendingPathComponent(filePath)
                    var isFileDirectory: ObjCBool = false
                    
                    // Gizli dosyaları atla
                    if filePath.hasPrefix(".") { continue }
                    
                    guard fileManager.fileExists(atPath: fullPath, isDirectory: &isFileDirectory) else {
                        continue
                    }
                    
                    if !isFileDirectory.boolValue {
                        // Dosya ise
                        do {
                            let attributes = try fileManager.attributesOfItem(atPath: fullPath)
                            if let fileSize = attributes[.size] as? Int64 {
                                totalSize += fileSize
                                processedFiles += 1
                            }
                        } catch {
                            // Dosya okunamazsa atla (sessizce)
                            continue
                        }
                    }
                }
            }
            
            // Eğer hiç dosya işlenmediyse ama klasör varsa, 0 döndür (boş klasör)
            if processedFiles == 0 && fileCount == 0 {
                return 0
            }
        } else {
            // Tek bir dosya ise
            do {
                let attributes = try fileManager.attributesOfItem(atPath: path)
                if let fileSize = attributes[.size] as? Int64 {
                    totalSize = fileSize
                } else {
                    return nil
                }
            } catch {
                print("⚠️ getDirectorySize: Dosya okuma hatası: \(path) - \(error.localizedDescription)")
                return nil
            }
        }
        
        // 0 bile olsa döndür (boş klasörler için)
        return totalSize
    }
    
    private func deleteItem(at path: String) -> Int64 {
        guard fileManager.fileExists(atPath: path) else { return 0 }
        
        let size = getDirectorySize(at: path) ?? 0
        
        do {
            try fileManager.removeItem(atPath: path)
            return size
        } catch {
            print("Silme hatası: \(path) - \(error.localizedDescription)")
            return 0
        }
    }
    
    func analyzeCache(type: CacheType, completion: @escaping ([CacheAnalysisResult]) -> Void) {
        print("🔍 Analiz başlatılıyor: \(getCacheTypeName(type))")
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                print("❌ Self nil oldu")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            DispatchQueue.main.async {
                self.isAnalyzing = true
                self.progress = 0.0
                self.currentTask = "Analiz ediliyor..."
            }
            
            var results: [CacheAnalysisResult] = []
            let typesToAnalyze: [CacheType]
            
            if type == .all {
                typesToAnalyze = [.userCache, .systemCache, .browserCache, .logs, .trash, .derivedData]
            } else {
                typesToAnalyze = [type]
            }
            
            print("📊 Analiz edilecek türler: \(typesToAnalyze.count)")
            
            // Her cache türünü analiz et
            for (index, cacheType) in typesToAnalyze.enumerated() {
                print("🔎 Analiz ediliyor: \(self.getCacheTypeName(cacheType))")
                
                DispatchQueue.main.async {
                    self.currentTask = "Analiz ediliyor: \(self.getCacheTypeName(cacheType))"
                    self.progress = Double(index) / Double(typesToAnalyze.count)
                }
                
                // Cache öğelerini al (hata yönetimi ile)
                let items = self.getCacheItems(for: cacheType)
                print("📁 \(self.getCacheTypeName(cacheType)): \(items.count) öğe bulundu")
                
                // Eğer öğe yoksa ama klasör varsa, en azından klasörü göster
                if items.isEmpty {
                    print("⚠️ \(self.getCacheTypeName(cacheType)) için hiç öğe bulunamadı")
                }
                
                // Her öğe için progress güncelle (sadece ilk birkaç öğe için detaylı göster)
                let itemsToShowProgress = min(items.count, 10)
                for (itemIndex, item) in items.prefix(itemsToShowProgress).enumerated() {
                    let progressValue = (Double(index) + Double(itemIndex) / Double(max(itemsToShowProgress, 1))) / Double(typesToAnalyze.count)
                    DispatchQueue.main.async {
                        self.currentTask = "Analiz ediliyor: \(self.getCacheTypeName(cacheType)) - \(item.name)"
                        self.progress = progressValue
                    }
                }
                
                // Toplam boyutu hesapla (hata yönetimi ile)
                var totalSize: Int64 = 0
                for item in items {
                    totalSize += item.size
                }
                
                print("💾 \(self.getCacheTypeName(cacheType)): Toplam boyut: \(self.formatBytes(totalSize))")
                
                results.append(CacheAnalysisResult(
                    type: cacheType,
                    totalSize: totalSize,
                    itemCount: items.count,
                    items: items
                ))
            }
            
            print("✅ Analiz tamamlandı: \(results.count) sonuç")
            
            DispatchQueue.main.async {
                self.isAnalyzing = false
                self.progress = 1.0
                self.currentTask = "Analiz tamamlandı"
                self.analysisResults = results
                completion(results)
            }
        }
    }
    
    func getCacheTypeName(_ type: CacheType) -> String {
        switch type {
        case .userCache: return "Kullanıcı Cache'leri"
        case .systemCache: return "Sistem Cache'leri"
        case .browserCache: return "Tarayıcı Cache'leri"
        case .logs: return "Log Dosyaları"
        case .trash: return "Çöp Kutusu"
        case .derivedData: return "Xcode Derived Data"
        case .all: return "Tümü"
        }
    }
    
    func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

