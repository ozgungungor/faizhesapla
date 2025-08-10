import SwiftUI
import SwiftData
import CloudKit
import GoogleMobileAds // AdBannerView için gerekli

// MARK: - Renk Eklentisi
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:(a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}


// MARK: - Global Hesaplama Fonksiyonu
func calculateCompoundReturn(initialAmount: Double, annualRate: Double, withholding: Double, days: Int, fixedDemand: Double, demandPercentage: Double?) -> Double {
    var actualDemandAmount = fixedDemand
    if let percentage = demandPercentage, percentage > 0 {
        actualDemandAmount = initialAmount * (percentage / 100.0)
    }
    let interestBearingPrincipal = initialAmount - actualDemandAmount
    guard interestBearingPrincipal > 0, days > 0, annualRate > 0 else { return 0 }
    
    var currentPrincipal = interestBearingPrincipal
    let dailyRateFactor = annualRate / 365 / 100
    let withholdingFactor = withholding / 100

    for _ in 1...days {
        let grossInterestForDay = currentPrincipal * dailyRateFactor
        let taxForDay = grossInterestForDay * withholdingFactor
        let netInterestForDay = grossInterestForDay - taxForDay
        currentPrincipal += netInterestForDay
    }
    
    return currentPrincipal - interestBearingPrincipal
}


// MARK: - Hesaplama Modu Seçimi
enum CalculationMode: String, CaseIterable, Identifiable {
    case automatic = "Bankaları Karşılaştır"
    case manual = "Manuel Hesapla"
    
    var id: Self { self }
}

// MARK: - Ana Görünüm (DÜZENLENDİ)
struct MainView: View {
    @State private var selectedMode: CalculationMode = .automatic

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                VStack(spacing: 0) {
                    Picker("Hesaplama Modu", selection: $selectedMode) {
                        ForEach(CalculationMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    switch selectedMode {
                    case .automatic:
                        AutomaticCalculatorView()
                    case .manual:
                        ManualCalculatorView()
                    }
                }
                // YENİ: İçeriğin alt kısmına 50 point boşluk ekleyerek
                // banner'ın üzerini kapatmasını engelliyoruz.
                .padding(.bottom, 50)
                .navigationTitle("FaizHesapla")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color(.systemGroupedBackground)) // Arka plan rengini ayarlar
            }
            
            // AdMob Banner'ı en altta ve her zaman görünür
            AdBannerView()
                .frame(height: 50)
        }
        .ignoresSafeArea(.keyboard) // Klavyenin reklamı yukarı itmesini engellemek için
    }
}

// MARK: - Otomatik Hesaplama (Banka Verileri) Görünümü
struct AutomaticCalculatorView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\InterestRate.bankName), SortDescriptor(\InterestRate.minimumAmount)])
    private var rates: [InterestRate]
    
    @State private var amountText = "100 000"
    @State private var numberOfDaysText = "32"
    @State private var showingResetAlert = false
    @State private var showingResultAlert = false
    @State private var resultMessage = ""
    
    @State private var isUserAdmin = false
    
    private var groupedRates: [String: [InterestRate]] {
        Dictionary(grouping: rates, by: { $0.bankName })
    }
    
    private var amount: Double {
        Double(amountText.replacingOccurrences(of: " ", with: "")) ?? 0
    }
    private var numberOfDays: Int { Int(numberOfDaysText) ?? 1 }

    private var sortedBanks: [(bankName: String, rates: [InterestRate])] {
        let allBanksWithInfo = groupedRates.map { (bankName, rates) -> (bankName: String, rates: [InterestRate], netReturn: Double, found: Bool) in
            if let tier = findApplicableTier(for: amount, in: rates) {
                let bestRate = max(tier.digitalWelcomeRate, tier.standardContinuationRate)
                let netReturn = calculateCompoundReturn(
                    initialAmount: amount,
                    annualRate: bestRate,
                    withholding: tier.withholdingRate,
                    days: numberOfDays,
                    fixedDemand: tier.demandDepositMinimum,
                    demandPercentage: tier.demandPercentage
                )
                return (bankName, rates, netReturn, true)
            } else {
                return (bankName, rates, 0.0, false)
            }
        }

        let foundBanks = allBanksWithInfo.filter { $0.found }.sorted { $0.netReturn > $1.netReturn }
        let unfoundBanks = allBanksWithInfo.filter { !$0.found }.sorted { $0.bankName.localizedCompare($1.bankName) == .orderedAscending }
        
        let combinedList = foundBanks + unfoundBanks
        
        return combinedList.map { (bankName: $0.bankName, rates: $0.rates) }
    }

    var body: some View {
        List {
            Section(header: Text("Giriş Bilgileri")) {
                HStack {
                    Text("Yatırılacak Miktar")
                        .font(.subheadline)
                    TextField("Miktar", text: $amountText)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .onChange(of: amountText) { oldValue, newValue in
                            let cleanedValue = newValue.filter { "0123456789".contains($0) }
                            if let number = Double(cleanedValue) {
                                let formatter = NumberFormatter()
                                formatter.numberStyle = .decimal
                                formatter.groupingSeparator = " "
                                if let formattedValue = formatter.string(from: NSNumber(value: number)) {
                                    if amountText != formattedValue {
                                        amountText = formattedValue
                                    }
                                }
                            }
                        }
                }
                HStack {
                    Text("Gün Sayısı")
                        .font(.subheadline)
                    TextField("Gün", text: $numberOfDaysText)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                }
            }
            
            ForEach(sortedBanks, id: \.bankName) { bankInfo in
                Section(
                    header: HStack(spacing: 8) {
                        Circle()
                            .fill(Color(hex: bankInfo.rates.first?.colorHex ?? "#CCCCCC"))
                            .frame(width: 10, height: 10)
                        Text(bankInfo.bankName.uppercased(with: Locale(identifier: "tr_TR")))
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    .padding(.vertical, 4)
                ) {
                    if let applicableTier = findApplicableTier(for: amount, in: bankInfo.rates) {
                        RateTierView(tier: applicableTier, amount: amount, numberOfDays: numberOfDays)
                    } else {
                        Text("Girdiğiniz tutar için uygun bir oran bulunamadı.").foregroundColor(.secondary)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .scrollDismissesKeyboard(.immediately)
        .onAppear {
            checkIfUserIsAdmin()
            fetchCloudKitData()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if isUserAdmin {
                        Button(role: .destructive) {
                            showingResetAlert = true
                        } label: {
                            Image(systemName: "exclamationmark.triangle.fill")
                        }
                    }
                    
                    Button(action: fetchCloudKitData) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .alert("Tüm Verileri Sil ve Eşitle?", isPresented: $showingResetAlert) {
            Button("Onayla", role: .destructive) {
                // CloudKitMasterReset.deleteAllThenSync { ... }
            }
            Button("İptal", role: .cancel) { }
        } message: {
            Text("Bu işlem geri alınamaz. Sunucudaki tüm veriler silinip uygulamadaki güncel banka listesiyle değiştirilecektir.")
        }
        .alert("İşlem Tamamlandı", isPresented: $showingResultAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(resultMessage)
        }
    }
    
    private func checkIfUserIsAdmin() {
        CKContainer.default().fetchUserRecordID { recordID, error in
            if let error = error {
                print("❌ HATA: Kullanıcı kimliği alınamadı: \(error.localizedDescription)")
                DispatchQueue.main.async { self.isUserAdmin = false }
                return
            }
            
            guard let recordID = recordID else {
                print("⚠️ UYARI: Kullanıcı kimliği boş geldi.")
                DispatchQueue.main.async { self.isUserAdmin = false }
                return
            }
            
            print("ℹ️ Giriş yapan kullanıcının Record Name'i: \(recordID.recordName)")

            let adminRecordName = "_5edae2bf78e60c91aacd005f66f381da"

            DispatchQueue.main.async {
                self.isUserAdmin = (recordID.recordName == adminRecordName)
                if self.isUserAdmin {
                    print("✅ Admin kullanıcısı doğrulandı.")
                }
            }
        }
    }
    
    private func findApplicableTier(for amount: Double, in bankRates: [InterestRate]) -> InterestRate? {
        return bankRates.first { rate in
            amount >= rate.minimumAmount && amount <= rate.maximumAmount
        }
    }
    
    private func fetchCloudKitData() {
        // CloudKit veri çekme fonksiyonunuz...
    }
}


// MARK: - Manuel Hesaplama Görünümü
struct ManualCalculatorView: View {
    @State private var amountText = "100 000"
    @State private var daysText = "32"
    @State private var rateText = "50,0"
    @State private var withholdingText = "17,5"

    private var amount: Double { Double(amountText.replacingOccurrences(of: " ", with: "")) ?? 0 }
    private var days: Int { Int(daysText) ?? 0 }
    private var annualRate: Double { Double(rateText.replacingOccurrences(of: ",", with: ".")) ?? 0 }
    private var withholding: Double { Double(withholdingText.replacingOccurrences(of: ",", with: ".")) ?? 0 }

    private var compoundNetReturn: Double {
        calculateManualCompoundReturn(principal: amount, annualRate: annualRate, days: days, withholding: withholding)
    }
    
    private var simpleNetReturn: Double {
        calculateManualSimpleReturn(principal: amount, annualRate: annualRate, days: days, withholding: withholding)
    }
    
    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }

    var body: some View {
        Form {
            Section(header: Text("Giriş Bilgileri")) {
                HStack {
                    Text("Ana Para (₺)")
                        .font(.subheadline)
                    TextField("Ana Para", text: $amountText)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .onChange(of: amountText) { oldValue, newValue in
                            let cleanedValue = newValue.filter { "0123456789".contains($0) }
                            if let number = Double(cleanedValue) {
                                let formatter = NumberFormatter()
                                formatter.numberStyle = .decimal
                                formatter.groupingSeparator = " "
                                if let formattedValue = formatter.string(from: NSNumber(value: number)) {
                                    if amountText != formattedValue {
                                        amountText = formattedValue
                                    }
                                }
                            }
                        }
                }
                HStack {
                    Text("Gün Sayısı")
                        .font(.subheadline)
                    TextField("Gün", text: $daysText)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                }
                HStack {
                    Text("Yıllık Brüt Faiz (%)")
                        .font(.subheadline)
                    TextField("Oran", text: $rateText)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
                HStack {
                    Text("Stopaj (%)")
                        .font(.subheadline)
                    TextField("Stopaj", text: $withholdingText)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
            }
            
            Section(header: Text("Sonuçlar")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bileşik Getiri")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                
                    HStack {
                        Text("Net Getiri:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(formatNumber(compoundNetReturn)) ₺")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    HStack {
                        Text("Vade Sonu Toplam:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(formatNumber(amount + compoundNetReturn)) ₺")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }.padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Basit Getiri")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)

                    HStack {
                        Text("Net Getiri:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(formatNumber(simpleNetReturn)) ₺")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    HStack {
                        Text("Vade Sonu Toplam:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(formatNumber(amount + simpleNetReturn)) ₺")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }.padding(.vertical, 4)
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
    private func calculateManualSimpleReturn(principal: Double, annualRate: Double, days: Int, withholding: Double) -> Double {
        guard principal > 0, days > 0, annualRate > 0 else { return 0 }
        let dailyRateFactor = annualRate / 365 / 100
        let totalGrossInterest = principal * dailyRateFactor * Double(days)
        let totalTax = totalGrossInterest * (withholding / 100)
        return totalGrossInterest - totalTax
    }
    
    private func calculateManualCompoundReturn(principal: Double, annualRate: Double, days: Int, withholding: Double) -> Double {
        guard principal > 0, days > 0, annualRate > 0 else { return 0 }
        var currentPrincipal = principal
        let dailyRateFactor = annualRate / 365 / 100
        let withholdingFactor = withholding / 100
        for _ in 1...days {
            let grossInterestForDay = currentPrincipal * dailyRateFactor
            let taxForDay = grossInterestForDay * withholdingFactor
            let netInterestForDay = grossInterestForDay - taxForDay
            currentPrincipal += netInterestForDay
        }
        return currentPrincipal - principal
    }
}


// MARK: - Yardımcı View'lar
struct RateTierView: View {
    let tier: InterestRate
    let amount: Double
    let numberOfDays: Int
    
    private var highestAvailableRateInfo: (label: String, rate: Double) {
        if tier.digitalWelcomeRate == tier.standardContinuationRate {
            return ("Faiz Oranı", tier.digitalWelcomeRate)
        }
        
        let potentialRates = [
            ("Faiz Oranı", tier.digitalWelcomeRate),
            ("Standart/Devam Faizi", tier.standardContinuationRate)
        ]
        
        if let bestRate = potentialRates.max(by: { $0.1 < $1.1 }), bestRate.1 > 0 {
            return bestRate
        }
        
        return ("Standart/Devam Faizi", tier.standardContinuationRate)
    }

    private var displayableDemandText: String? {
        if let percentage = tier.demandPercentage, percentage > 0 {
            let demandValue = amount * (percentage / 100.0)
            return "Vadesiz Alt Limit (%_`\(Int(percentage))`_): \(Int(demandValue)) ₺ (Bu tutara faiz işlemez)"
        }
        if tier.demandDepositMinimum > 0 {
            return "Vadesiz Alt Limit: \(Int(tier.demandDepositMinimum)) ₺ (Bu tutara faiz işlemez)"
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tutar Aralığı: \(Int(tier.minimumAmount)) ₺ - \(Int(tier.maximumAmount)) ₺")
                .font(.caption)
                .foregroundColor(.secondary)

            if let demandText = displayableDemandText {
                Text(try! AttributedString(markdown: demandText))
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.bottom, 2)
            }
            
            let bestRateInfo = highestAvailableRateInfo
            RateRow(
                label: bestRateInfo.label,
                rate: bestRateInfo.rate,
                amount: amount,
                withholding: tier.withholdingRate,
                numberOfDays: numberOfDays,
                demandDepositMinimum: tier.demandDepositMinimum,
                demandPercentage: tier.demandPercentage
            )
        }
        .padding(.vertical, 4)
    }
}

struct RateRow: View {
    let label: String
    let rate: Double
    let amount: Double
    let withholding: Double
    let numberOfDays: Int
    let demandDepositMinimum: Double
    let demandPercentage: Double?

    private var totalNetReturn: Double {
        calculateCompoundReturn(initialAmount: amount, annualRate: rate, withholding: withholding, days: numberOfDays, fixedDemand: demandDepositMinimum, demandPercentage: self.demandPercentage)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                Text("Yıllık Brüt Oran: %\(rate, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Net Getiri (\(numberOfDays) gün)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(totalNetReturn, specifier: "%.2f") ₺")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        }
    }
}


// InterestRate ve CloudKitMasterReset modellerinizin de
// kodda tanımlı olduğunu varsayıyorum.
