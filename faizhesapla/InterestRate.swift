import Foundation
import SwiftData
import CloudKit

@Model
final class InterestRate {
    var bankName: String = ""
    var isActive: Bool = true
    var withholdingRate: Double = 0.0
    var startDate: Date = Date()
    var endDate: Date?
    @Attribute(.externalStorage)
    var notes: String = ""
    var sourceURL: String?
    
    // Katmanlı yapı alanları
    var minimumAmount: Double = 0.0
    var maximumAmount: Double = 0.0
    var demandDepositMinimum: Double = 0.0      // Sabit Vadesiz Alt Limit (örn: 5000 TL)
    var branchWelcomeRate: Double = 0.0
    var digitalWelcomeRate: Double = 0.0
    var videoCallWelcomeRate: Double = 0.0
    var standardContinuationRate: Double = 0.0
    
    // Yüzdesel vadesiz bakiye kuralı için eklendi (örn: %10)
    var demandPercentage: Double?

    // --- YENİ EKLENEN RENK ALANI ---
    var colorHex: String?

    init() { }

    /// CloudKit CKRecord'dan InterestRate nesnesi oluşturur
    convenience init?(record: CKRecord) {
        guard
            let bankName = record["bankName"] as? String,
            let isActive = record["isActive"] as? Bool
        else {
            return nil
        }
        
        self.init()
        
        self.bankName = bankName
        self.isActive = isActive
        self.withholdingRate = record["withholdingRate"] as? Double ?? 17.5
        self.startDate = record["startDate"] as? Date ?? self.startDate
        self.endDate = record["endDate"] as? Date
        self.notes = record["notes"] as? String ?? self.notes
        self.sourceURL = record["sourceURL"] as? String
        
        self.minimumAmount = record["minimumAmount"] as? Double ?? 0.0
        self.maximumAmount = record["maximumAmount"] as? Double ?? 0.0
        self.demandDepositMinimum = record["demandDepositMinimum"] as? Double ?? 0.0
        self.branchWelcomeRate = record["branchWelcomeRate"] as? Double ?? 0.0
        self.digitalWelcomeRate = record["digitalWelcomeRate"] as? Double ?? 0.0
        self.videoCallWelcomeRate = record["videoCallWelcomeRate"] as? Double ?? 0.0
        self.standardContinuationRate = record["standardContinuationRate"] as? Double ?? 0.0
        
        self.demandPercentage = record["demandPercentage"] as? Double
        
        // --- YENİ EKLENEN RENK OKUMASI ---
        self.colorHex = record["bankColorHex"] as? String
    }
}
