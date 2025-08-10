import SwiftUI
import GoogleMobileAds

// UIKit'in GADBannerView'ini SwiftUI'da kullanmak için köprü.
struct AdBannerView: UIViewRepresentable {

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner) // Standart banner boyutu
        // ❗️ BURAYA KENDİ BANNER REKLAM BİRİMİ ID'NİZİ GİRİN
        bannerView.adUnitID = "ca-app-pub-4244659004257886~2678732633" // Bu Google'ın test ID'sidir.
        bannerView.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first?
            .rootViewController
        bannerView.load(Request())
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // Banner'da bir güncelleme yapmak gerekirse burası kullanılır.
        // Şimdilik boş kalabilir.
    }
}
