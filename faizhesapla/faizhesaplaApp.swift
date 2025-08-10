import SwiftUI
import SwiftData
import GoogleMobileAds // AdMob için import eklendi

@main
struct FaizHesaplaApp: App {
    
    // YENİ: AdMob SDK'sını uygulama başlarken başlatmak için.
    init() {
        MobileAds.shared.start()
    }

    // Sizin tarafınızdan güncellenen yerel veritabanı yapılandırması.
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            InterestRate.self,
        ])
        // Sadece şema ve yerel depolama belirten basit bir konfigürasyon.
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            // Konteyneri bu basit yapılandırma ile oluşturuyoruz.
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(sharedModelContainer)
    }
}
