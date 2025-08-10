import Foundation

struct BankDataProvider {
    
    // MARK: - Veri Yapıları
    struct RateTier {
        let min: Double
        let max: Double
        let demand: Double
        let standard: Double
        let welcome: Double
    }
    
    struct Bank {
        let name: String
        let withholdingRate: Double
        let tiers: [RateTier]
        let demandPercentage: Double?
        let colorHex: String
    }
    
    // MARK: - Banka Veri Listesi
    static let allBanks: [Bank] = [
        
        .init(
            name: "Anadolu Bank Renkli Hesap",
            withholdingRate: 17.5,
            tiers: [
                .init(min: 1000, max: 49999, demand: 2500, standard: 40.00, welcome: 50.0),
                .init(min: 50000, max: 99999, demand: 5000, standard: 40.00, welcome: 50.0),
                .init(min: 100000, max: 249999, demand: 12500, standard: 40.00, welcome: 50.0),
                .init(min: 250000, max: 499999, demand: 25000, standard: 40.00, welcome: 50.0),
                .init(min: 500000, max: 999999, demand: 50000, standard: 41.00, welcome: 50.0),
                .init(min: 1000000, max: 1999999, demand: 90000, standard: 41.00, welcome: 50.0),
                .init(min: 2000000, max: 2999999, demand: 200000, standard: 41.00, welcome: 50.0),
                .init(min: 3000000, max: 3999999, demand: 300000, standard: 41.00, welcome: 50.0),
                .init(min: 4000000, max: 4999999, demand: 400000, standard: 41.00, welcome: 50.0),
                .init(min: 5000000, max: 6999999, demand: 600000, standard: 41.00, welcome: 49.0),
                .init(min: 7000000, max: 8499999, demand: 700000, standard: 41.00, welcome: 49.0),
                .init(min: 8500000, max: 10000000, demand: 900000, standard: 41.00, welcome: 49.0)
            ],
            demandPercentage: nil,
            colorHex: "#008AFF"
        ),
        
        .init(
            name: "TEB Marifetli Hesap",
            withholdingRate: 17.5,
            tiers: [
                .init(min: 2000, max: 49999, demand: 5000, standard: 14.25, welcome: 47.25),
                .init(min: 50000, max: 99999, demand: 7500, standard: 24.25, welcome: 47.25),
                .init(min: 100000, max: 299999, demand: 15000, standard: 34.25, welcome: 47.25),
                .init(min: 300000, max: 999999, demand: 30000, standard: 41.25, welcome: 47.25),
                .init(min: 1000000, max: 3999999, demand: 150000, standard: 42.25, welcome: 47.25),
                .init(min: 4000000, max: 7000000, demand: 425000, standard: 41.25, welcome: 47.25)
            ],
            demandPercentage: nil,
            colorHex: "#E71D36"
        ),
        
        .init(
            name: "Akbank Serbest Plus Hesap",
            withholdingRate: 17.5,
            tiers: [
                .init(min: 10000, max: 10000000, demand: 0, standard: 47.0, welcome: 47.0),
                .init(min: 10000001, max: 100_000_000_000_000.0, demand: 0, standard: 4.0, welcome: 4.0)
            ],
            demandPercentage: 10.0,
            colorHex: "#E30613"
        ),

        .init(
            name: "Alternatif Bank VOV Hesap",
            withholdingRate: 17.5,
            tiers: [
                .init(min: 20000, max: 250000, demand: 20000, standard: 39.0, welcome: 49.0),
                .init(min: 250001, max: 500000, demand: 40000, standard: 39.0, welcome: 49.0),
                .init(min: 500001, max: 1000000, demand: 75000, standard: 39.0, welcome: 49.0),
                .init(min: 1000001, max: 1500000, demand: 150000, standard: 39.0, welcome: 49.0),
                .init(min: 1500001, max: 2000000, demand: 175000, standard: 39.0, welcome: 49.0),
                .init(min: 2000001, max: 3000000, demand: 250000, standard: 39.0, welcome: 49.0),
                .init(min: 3000001, max: 4000000, demand: 350000, standard: 39.0, welcome: 49.0),
                .init(min: 4000001, max: 5000000, demand: 450000, standard: 39.0, welcome: 49.0),
                .init(min: 5000001, max: 7500000, demand: 600000, standard: 38.0, welcome: 48.0),
                .init(min: 7500001, max: 10000000, demand: 900000, standard: 38.0, welcome: 48.0),
                .init(min: 10000001, max: 15000000, demand: 1500000, standard: 38.0, welcome: 48.0),
                .init(min: 15000001, max: 100_000_000_000_000.0, demand: 2500000, standard: 36.0, welcome: 46.0)
            ],
            demandPercentage: nil,
            colorHex: "#AA0719"
        ),
        
        .init(
            name: "HSBC Modern Hesap",
            withholdingRate: 17.5,
            tiers: [
                .init(min: 0,       max: 250000,    demand: 30000,  standard: 40.50, welcome: 46.0),
                .init(min: 250000.01, max: 500000,    demand: 40000,  standard: 40.75, welcome: 46.0),
                .init(min: 500000.01, max: 1000000,   demand: 60000,  standard: 41.00, welcome: 46.0),
                .init(min: 1000000.01,max: 1500000,   demand: 75000,  standard: 42.00, welcome: 46.0),
                .init(min: 1500000.01,max: 2000000,   demand: 100000, standard: 42.50, welcome: 46.0),
                .init(min: 2000000.01,max: 3000000,   demand: 150000, standard: 42.75, welcome: 46.0)
            ],
            demandPercentage: nil,
            colorHex: "#DB0011"
        ),
        
        .init(
            name: "Aktif Bank N Kolay",
            withholdingRate: 15.0,
            tiers: [
                .init(min: 0, max: 1000000, demand: 0, standard: 47.0, welcome: 47.0)
            ],
            demandPercentage: nil,
            colorHex: "#F15A29"
        ),
        
        .init(
            name: "GetirFinans",
            withholdingRate: 17.5,
            tiers: [
                .init(min: 2500,       max: 25000,     demand: 2500,    standard: 47.0, welcome: 47.0),
                .init(min: 25001,      max: 50000,     demand: 7500,    standard: 47.0, welcome: 47.0),
                .init(min: 50001,      max: 100000,    demand: 15000,   standard: 47.0, welcome: 47.0),
                .init(min: 100001,     max: 250000,    demand: 30000,   standard: 47.0, welcome: 47.0),
                .init(min: 250001,     max: 500000,    demand: 50000,   standard: 47.0, welcome: 47.0),
                .init(min: 500001,     max: 1000000,   demand: 75000,   standard: 47.0, welcome: 47.0),
                .init(min: 1000001,    max: 2000000,   demand: 125000,  standard: 47.0, welcome: 47.0),
                .init(min: 2000001,    max: 2150000,   demand: 150000,  standard: 47.0, welcome: 47.0),
                .init(min: 2150001,    max: 5150000,   demand: 150000,  standard: 30.0, welcome: 30.0),
                .init(min: 5150001,    max: 100_000_000_000_000.0, demand: 150000, standard: 30.0, welcome: 30.0)
            ],
            demandPercentage: nil,
            colorHex: "#5D3EBC"
        ),
        
        .init(
            name: "Fibabanka Kiraz Hesap",
            withholdingRate: 17.5,
            tiers: [
                .init(min: 10000, max: 24999,   demand: 5000,  standard: 40.0, welcome: 47.0),
                .init(min: 25000, max: 49999,   demand: 10000, standard: 40.0, welcome: 47.0),
                .init(min: 50000, max: 99999,   demand: 15000, standard: 40.0, welcome: 47.0),
                .init(min: 100000,max: 249999,  demand: 25000, standard: 40.0, welcome: 47.0),
                .init(min: 250000,max: 499999,  demand: 50000, standard: 40.0, welcome: 47.0),
                .init(min: 500000,max: 999999,  demand: 75000, standard: 41.0, welcome: 47.0),
                .init(min: 1000000,max:1999999, demand: 150000,standard: 42.0, welcome: 47.0),
                .init(min: 2000000,max:5000000, demand: 250000,standard: 43.0, welcome: 47.0)
            ],
            demandPercentage: nil,
            colorHex: "#003D7E"
        ),
        
        .init(
            name: "ING Turuncu Hesap",
            withholdingRate: 17.5,
            tiers: [
                .init(min: 3000, max: 9999, demand: 3000, standard: 23.0, welcome: 49.0),
                .init(min: 10000, max: 49999, demand: 5000, standard: 23.0, welcome: 49.0),
                .init(min: 50000, max: 99999, demand: 7500, standard: 23.0, welcome: 49.0),
                .init(min: 100000, max: 249999, demand: 15000, standard: 23.0, welcome: 49.0),
                .init(min: 250000, max: 499999, demand: 30000, standard: 23.0, welcome: 49.0),
                .init(min: 500000, max: 999999, demand: 75000, standard: 23.0, welcome: 49.0),
                .init(min: 1000000, max: 1999999, demand: 150000, standard: 23.0, welcome: 49.0),
                .init(min: 2000000, max: 4999999, demand: 285000, standard: 23.0, welcome: 49.0),
                .init(min: 5000000, max: 7499999, demand: 600000, standard: 23.0, welcome: 49.0),
                .init(min: 7500000, max: 9999999, demand: 900000, standard: 23.0, welcome: 49.0),
                .init(min: 10000000, max: 14999999, demand: 1250000, standard: 23.0, welcome: 49.0),
                .init(min: 15000000, max: 100_000_000_000_000.0, demand: 1250000, standard: 23.0, welcome: 23.0)
            ],
            demandPercentage: nil,
            colorHex: "#FF6000"
        ),
        
        .init(
            name: "Odeabank Oksijen Hesap",
            withholdingRate: 17.5,
            tiers: [
                .init(min: 0, max: 25000, demand: 7500, standard: 44.0, welcome: 47.0),
                .init(min: 25000.01, max: 50000, demand: 7500, standard: 44.0, welcome: 47.0),
                .init(min: 50000.01, max: 100000, demand: 10000, standard: 44.0, welcome: 47.0),
                .init(min: 100000.01, max: 250000, demand: 20000, standard: 44.0, welcome: 47.0),
                .init(min: 250000.01, max: 500000, demand: 40000, standard: 44.0, welcome: 47.0),
                .init(min: 500000.01, max: 750000, demand: 75000, standard: 44.0, welcome: 47.0),
                .init(min: 750000.01, max: 1000000, demand: 125000, standard: 44.0, welcome: 47.0),
                .init(min: 1000000.01, max: 2000000, demand: 200000, standard: 44.0, welcome: 47.0),
                .init(min: 2000000.01, max: 3000000, demand: 350000, standard: 44.0, welcome: 47.0),
                .init(min: 3000000.01, max: 4000000, demand: 450000, standard: 44.0, welcome: 47.0),
                .init(min: 4000000.01, max: 5000000, demand: 600000, standard: 44.0, welcome: 47.0),
                .init(min: 5000000.01, max: 6000000, demand: 750000, standard: 44.0, welcome: 47.0),
                .init(min: 6000000.01, max: 7000000, demand: 900000, standard: 44.0, welcome: 47.0),
                .init(min: 7000000.01, max: 20000000, demand: 1000000, standard: 13.0, welcome: 13.5)
            ],
            demandPercentage: nil,
            colorHex: "#ED1C24"
        ),
        
        .init(
            name: "Denizbank Kaptan Hesap",
            withholdingRate: 17.5,
            tiers: [
                .init(min: 10000, max: 99999, demand: 10000, standard: 38.0, welcome: 48.0),
                .init(min: 100000, max: 249999, demand: 20000, standard: 38.0, welcome: 48.0),
                .init(min: 250000, max: 499999, demand: 40000, standard: 38.0, welcome: 48.0),
                .init(min: 500000, max: 749999, demand: 70000, standard: 38.0, welcome: 48.0),
                .init(min: 750000, max: 1249999, demand: 100000, standard: 38.0, welcome: 48.0),
                .init(min: 1250000, max: 1499999, demand: 125000, standard: 38.0, welcome: 48.0),
                .init(min: 1500000, max: 1999999, demand: 150000, standard: 38.0, welcome: 48.0),
                .init(min: 2000000, max: 2999999, demand: 200000, standard: 38.0, welcome: 48.0),
                .init(min: 3000000, max: 4999999, demand: 300000, standard: 38.0, welcome: 48.0),
                .init(min: 5000000, max: 7499999, demand: 600000, standard: 38.0, welcome: 48.0),
                .init(min: 7500000, max: 10000000, demand: 900000, standard: 38.0, welcome: 48.0)
            ],
            demandPercentage: nil,
            colorHex: "#E30613"
        ),
        
            .init(
                name: "QNB Finansbank Kazandıran Günlük Hesap",
                withholdingRate: 17.5,
                tiers: [
                    .init(min: 7500,    max: 49999,    demand: 0, standard: 42.00, welcome: 46.00),
                    .init(min: 50000,   max: 99999,    demand: 0, standard: 42.00, welcome: 46.00),
                    .init(min: 100000,  max: 499999,   demand: 0, standard: 43.50, welcome: 46.00),
                    .init(min: 500000,  max: 999999,   demand: 0, standard: 43.50, welcome: 46.00),
                    .init(min: 1000000, max: 2499999,  demand: 0, standard: 43.50, welcome: 46.00),
                    .init(min: 2500000, max: 4999999,  demand: 0, standard: 43.50, welcome: 46.00),
                    .init(min: 5000000, max: 9999999,  demand: 0, standard: 42.00, welcome: 46.00),
                    .init(min: 10000000,max: 29999999, demand: 0, standard: 35.00, welcome: 34.75),
                    .init(min: 30000000,max: 100_000_000_000_000.0, demand: 0, standard: 31.50, welcome: 32.00)
                ],
                demandPercentage: nil,
                colorHex: "#111E56"
            ),
        
        .init(
            name: "Şekerbank Gece Gündüz Hesabı",
            withholdingRate: 17.5,
            tiers: [
                .init(min: 5000,    max: 49999,   demand: 5000,  standard: 35.0, welcome: 48.0),
                .init(min: 50000,   max: 99999,   demand: 10000, standard: 39.0, welcome: 48.0),
                .init(min: 100000,  max: 249999,  demand: 18000, standard: 40.0, welcome: 48.0),
                .init(min: 250000,  max: 499999,  demand: 35000, standard: 41.0, welcome: 48.0),
                .init(min: 500000,  max: 999999,  demand: 75000, standard: 42.0, welcome: 48.0),
                .init(min: 1000000, max: 2999999, demand: 150000,standard: 43.0, welcome: 48.0),
                .init(min: 3000000, max: 4999999, demand: 325000,standard: 43.0, welcome: 48.0),
                .init(min: 5000000, max: 9999999, demand: 1000000, standard: 43.0, welcome: 48.0)
            ],
            demandPercentage: nil,
            colorHex: "#00965E"
        ),
        
        .init(
            name: "Türkiye Finans Günlük Hesap",
            withholdingRate: 17.5,
            tiers: [
                .init(min: 5000, max: 20000, demand: 5000, standard: 48.0, welcome: 50.0),
                .init(min: 20001, max: 50000, demand: 10000, standard: 48.0, welcome: 50.0),
                .init(min: 50001, max: 100000, demand: 15000, standard: 48.0, welcome: 50.0),
                .init(min: 100001, max: 250000, demand: 25000, standard: 48.0, welcome: 50.0),
                .init(min: 250001, max: 500000, demand: 50000, standard: 48.0, welcome: 50.0),
                .init(min: 500001, max: 1000000, demand: 100000, standard: 48.0, welcome: 50.0),
                .init(min: 1000001, max: 2000000, demand: 200000, standard: 48.0, welcome: 50.0),
                .init(min: 2000001, max: 3000000, demand: 300000, standard: 48.0, welcome: 50.0),
                .init(min: 3000001, max: 4000000, demand: 400000, standard: 48.0, welcome: 50.0),
                .init(min: 4000001, max: 5000000, demand: 500000, standard: 48.0, welcome: 50.0)
            ],
            demandPercentage: nil,
            colorHex: "#009B8C"
        ),

        .init(
            name: "Vakıfbank Arı Hesabı",
            withholdingRate: 17.5,
            tiers: [
                .init(min: 5000, max: 100_000_000_000_000.0, demand: 5000, standard: 23.0, welcome: 45.0)
            ],
            demandPercentage: nil,
            colorHex: "#F7D000"
        ),

        .init(
            name: "Burgan Bank ON Plus Hesap",
            withholdingRate: 17.5,
            tiers: [
                .init(min: 8000,    max: 49999,   demand: 7500,  standard: 45.0, welcome: 49.0),
                .init(min: 50000,   max: 99999,   demand: 10000, standard: 45.0, welcome: 49.0),
                .init(min: 100000,  max: 249999,  demand: 17500, standard: 45.0, welcome: 49.0),
                .init(min: 250000,  max: 499999,  demand: 40000, standard: 43.0, welcome: 49.0),
                .init(min: 500000,  max: 749999,  demand: 70000, standard: 43.0, welcome: 47.0),
                .init(min: 750000,  max: 999999,  demand: 100000,standard: 43.0, welcome: 47.0),
                .init(min: 1000000, max: 1249999, demand: 120000,standard: 40.0, welcome: 45.5),
                .init(min: 1250000, max: 1499999, demand: 135000,standard: 40.0, welcome: 44.5),
                .init(min: 1500000, max: 1749999, demand: 150000,standard: 40.0, welcome: 44.5),
                .init(min: 1750000, max: 2000000, demand: 200000,standard: 40.0, welcome: 44.5)
            ],
            demandPercentage: nil,
            colorHex: "#002D62"
        )
    ]
}
