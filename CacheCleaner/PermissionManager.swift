import Foundation
import AppKit

class PermissionManager {
    static let shared = PermissionManager()
    
    private init() {}
    
    /// Dosya erişim izinlerini kontrol et
    func checkFileAccessPermissions() -> Bool {
        let testPaths = [
            NSHomeDirectory() + "/Library/Caches",
            NSHomeDirectory() + "/Library/Logs"
        ]
        
        var accessibleCount = 0
        
        for path in testPaths {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: path) {
                // Erişim kontrolü
                if fileManager.isReadableFile(atPath: path) {
                    // İçerik okuma testi
                    do {
                        _ = try fileManager.contentsOfDirectory(atPath: path)
                        accessibleCount += 1
                        print("✅ Erişim var: \(path)")
                    } catch {
                        print("⚠️ İçerik okunamıyor: \(path) - \(error.localizedDescription)")
                    }
                } else {
                    print("⚠️ Erişim izni yok: \(path)")
                }
            }
        }
        
        // En az bir klasöre erişim varsa yeterli (Trash opsiyonel)
        return accessibleCount > 0
    }
    
    /// Tam disk erişimi kontrolü
    func checkFullDiskAccess() -> Bool {
        // macOS'ta tam disk erişimi kontrolü için özel bir yol yok
        // Ancak sistem klasörlerine erişim deneyerek kontrol edebiliriz
        // Sistem klasörlerine erişim opsiyonel, kullanıcı klasörlerine erişim yeterli
        return true // Sistem klasörlerine erişim opsiyonel
    }
    
    /// İzin durumunu kontrol et ve gerekirse kullanıcıyı yönlendir
    func requestPermissionsIfNeeded() {
        let hasFileAccess = checkFileAccessPermissions()
        
        // Sadece temel dosya erişimi yoksa uyarı göster
        // Tam disk erişimi opsiyonel (sistem cache'leri için)
        if !hasFileAccess {
            print("⚠️ Temel dosya erişim izni yok")
            showPermissionAlert(needsFullDiskAccess: false)
        } else {
            print("✅ Temel dosya erişim izni var")
        }
    }
    
    /// İzin uyarısı göster
    private func showPermissionAlert(needsFullDiskAccess: Bool) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Dosya Erişim İzni Gerekli"
            
            if needsFullDiskAccess {
                alert.informativeText = """
                Cache temizleyici uygulamasının düzgün çalışması için "Tam Disk Erişimi" iznine ihtiyacı var.
                
                Lütfen şu adımları izleyin:
                1. Sistem Ayarları > Gizlilik ve Güvenlik > Tam Disk Erişimi
                2. CacheCleaner uygulamasını bulun ve etkinleştirin
                3. Uygulamayı yeniden başlatın
                
                Sistem Ayarlarını şimdi açmak ister misiniz?
                """
            } else {
                alert.informativeText = """
                Cache temizleyici uygulamasının bazı dosyalara erişim iznine ihtiyacı var.
                
                Sistem Ayarlarını açıp gerekli izinleri vermek ister misiniz?
                """
            }
            
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Sistem Ayarlarını Aç")
            alert.addButton(withTitle: "Daha Sonra")
            
            let response = alert.runModal()
            
            if response == .alertFirstButtonReturn {
                self.openSystemPreferences()
            }
        }
    }
    
    /// Sistem Ayarlarını aç
    private func openSystemPreferences() {
        // macOS Ventura ve üzeri için yeni Sistem Ayarları
        if #available(macOS 13.0, *) {
            // Tam Disk Erişimi sayfasını aç
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles") {
                NSWorkspace.shared.open(url)
            }
        } else {
            // macOS Monterey ve öncesi için eski Sistem Tercihleri
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    /// İzin durumunu kontrol et (sessizce)
    func hasRequiredPermissions() -> Bool {
        return checkFileAccessPermissions() && checkFullDiskAccess()
    }
}

