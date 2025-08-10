import Foundation
import CloudKit

// DİKKAT: Bu dosyanın nihai ve hatasız sürümüdür.
// Konteyner adı uyuşmazlığı hatasını gidermek için tüm "CKContainer.default()" çağrıları
// projenin özel konteyner adıyla ("iCloud.com.ozgungungor.Paynify") değiştirilmiştir.

struct CloudKitMasterReset {
    
    // Projenizin özel ve doğru konteyner kimliği
    private static let containerIdentifier = "iCloud.com.ozgungungor.Paynify"
    private static let container = CKContainer(identifier: containerIdentifier)
    
    // Ana tetikleyici fonksiyon
    static func deleteAllThenSync(completion: @escaping (Result<Int, Error>) -> Void) {
        print("💣 MASTER RESET BAŞLATILIYOR...")
        
        fetchAllRecordIDsToDelete { result in
            switch result {
            case .success(let allRecordIDs):
                guard !allRecordIDs.isEmpty else {
                    print("✅ Silinecek kayıt bulunamadı. Doğrudan ekleme adımına geçiliyor.")
                    saveNewRecords(completion: completion)
                    return
                }
                print("ℹ️ Silinecek toplam \(allRecordIDs.count) adet kayıt ID'si toplandı.")
                batchDeleteRecords(recordIDs: allRecordIDs) { error in
                    if let error = error {
                        print("❌ HATA: Toplu silme işlemi sırasında bir hata oluştu: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }
                    print("✅ Tüm eski kayıtlar başarıyla silindi.")
                    saveNewRecords(completion: completion)
                }
            case .failure(let error):
                print("❌ HATA: Silinecek kayıt ID'leri toplanırken hata oluştu: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // YARDIMCI FONKSİYON 1: Tüm kayıt ID'lerini cursor ile toplar
    private static func fetchAllRecordIDsToDelete(
        cursor: CKQueryOperation.Cursor? = nil,
        accumulatedIDs: [CKRecord.ID] = [],
        completion: @escaping (Result<[CKRecord.ID], Error>) -> Void
    ) {
        let queryOperation: CKQueryOperation
        if let cursor = cursor {
            queryOperation = CKQueryOperation(cursor: cursor)
        } else {
            let query = CKQuery(recordType: "InterestRate", predicate: NSPredicate(value: true))
            queryOperation = CKQueryOperation(query: query)
        }
        
        var recordIDsForThisPage: [CKRecord.ID] = []
        queryOperation.recordMatchedBlock = { (recordID, _) in recordIDsForThisPage.append(recordID) }
        
        queryOperation.queryResultBlock = { result in
            switch result {
            case .success(let nextCursor):
                let newAccumulatedIDs = accumulatedIDs + recordIDsForThisPage
                if let nextCursor = nextCursor {
                    fetchAllRecordIDsToDelete(cursor: nextCursor, accumulatedIDs: newAccumulatedIDs, completion: completion)
                } else {
                    completion(.success(newAccumulatedIDs))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        container.publicCloudDatabase.add(queryOperation) // <- DEĞİŞİKLİK
    }
    
    // YARDIMCI FONKSİYON 2: Gelen ID listesini 400'lük gruplar halinde siler
    private static func batchDeleteRecords(recordIDs: [CKRecord.ID], completion: @escaping (Error?) -> Void) {
        let group = DispatchGroup()
        var operationError: Error? = nil
        let chunks = recordIDs.chunked(into: 400)
        print("🗑️ \(recordIDs.count) kayıt, \(chunks.count) grup halinde silinecek...")
        
        for chunk in chunks {
            group.enter()
            let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: chunk)
            operation.modifyRecordsResultBlock = { result in
                if case .failure(let error) = result {
                    if operationError == nil { operationError = error }
                }
                group.leave()
            }
            container.publicCloudDatabase.add(operation) // <- DEĞİŞİKLİK
        }
        
        group.notify(queue: .main) { completion(operationError) }
    }
    
    // YARDIMCI FONKSİYON 3: Yeni kayıtları veritabanına ekler
    private static func saveNewRecords(completion: @escaping (Result<Int, Error>) -> Void) {
        var recordsToSave: [CKRecord] = []
        for bank in BankDataProvider.allBanks {
            for tier in bank.tiers {
                recordsToSave.append(createRecord(for: bank, tier: tier))
            }
        }
        
        print("💾 \(recordsToSave.count) adet yeni kayıt yükleniyor...")
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
        
        operation.modifyRecordsResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    print("🎉 BAŞARILI: \(recordsToSave.count) adet yeni kayıt yüklendi!")
                    completion(.success(recordsToSave.count))
                case .failure(let error):
                    print("❌ HATA: Yeni kayıtlar eklenirken hata: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        container.publicCloudDatabase.add(operation) // <- DEĞİŞİKLİK
    }

    private static func createRecord(for bank: BankDataProvider.Bank, tier: BankDataProvider.RateTier) -> CKRecord {
        // Bu fonksiyonda değişiklik yok
        let record = CKRecord(recordType: "InterestRate")
        record["bankName"] = bank.name
        record["withholdingRate"] = bank.withholdingRate
        record["bankColorHex"] = bank.colorHex
        if let percentage = bank.demandPercentage {
            record["demandPercentage"] = percentage
        }
        record["digitalWelcomeRate"] = tier.welcome
        record["branchWelcomeRate"] = tier.welcome
        record["videoCallWelcomeRate"] = tier.welcome
        record["minimumAmount"] = tier.min
        record["maximumAmount"] = tier.max
        record["demandDepositMinimum"] = tier.demand
        record["standardContinuationRate"] = tier.standard
        record["isActive"] = true
        return record
    }
}

// Array'i parçalara ayırmak için küçük bir yardımcı eklenti
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
