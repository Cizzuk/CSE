//
//  CloudKitManager.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/04/20.
//

import CloudKit
import Combine
import UIKit
import CryptoKit

final class CloudKitManager: ObservableObject {
    private let database: CKDatabase = CKContainer(identifier: "iCloud.net.cizzuk.cse").privateCloudDatabase
    private let userDefaults = CSEDataManager.userDefaults
    
    enum CKMStatus: Equatable {
        case idle
        case skipped
        case inProgress
        case success
        case failure
    }

    enum CKMOperation: Equatable {
        case none
        case availability
        case upload
        case fetchAll
        case delete
        case export
    }
    
    @Published var cloudKitAvailability: CKAccountStatus?
    @Published var allCSEs: [CSEDataManager.DeviceCSEs] = [] // All data from iCloud
    @Published var error: Error? // Error message
    @Published var currentStatus: CKMStatus = .idle
    @Published var currentOperation: CKMOperation = .none
    
    // Check CloudKit availability
    func checkCloudKitAvailability() {
        currentOperation = .availability
        currentStatus = .inProgress
        CKContainer(identifier: "iCloud.net.cizzuk.cse").accountStatus { status, error in
            DispatchQueue.main.async {
                self.cloudKitAvailability = status
                if let error = error {
                    self.error = error
                    self.currentStatus = .failure
                } else {
                    self.error = nil
                    self.currentStatus = .success
                }
            }
        }
    }
    
    // Create device name
    func createDeviceName() -> String {
        #if targetEnvironment(macCatalyst)
        return "Mac Catalyst / \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        #else
        return "\(UIDevice.current.name) / \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        #endif
    }
    
    // Upload CSEs
    func saveAll(mustUpload: Bool = false) {
        currentOperation = .upload
        // Skip when auto-backup off and not forced
        guard mustUpload || userDefaults.bool(forKey: "iCloudAutoBackup") else {
            self.currentStatus = .skipped
            self.error = nil
            print("CloudKit upload is disabled in settings.")
            return
        }
        self.currentStatus = .inProgress
        self.error = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            
            let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            let recordID = CKRecord.ID(recordName: deviceID)
            let record = CKRecord(recordType: "DeviceCSEs", recordID: recordID)
            var combinedDict: [String: Any] = [:]
            
            // Set record values
            record["deviceName"] = createDeviceName()
            record["version"] = CSEDataManager.currentVersion
            
            // DefaultCSE
            if userDefaults.bool(forKey: "useDefaultCSE") {
                let defaultCSE = CSEDataManager.getCSEData(.defaultCSE)
                let defaultCSEDict = CSEDataManager.CSEDataToDictionary(defaultCSE)
                let defaultCSEJSON = CSEDataManager.jsonDictToString(defaultCSEDict) ?? ""
                combinedDict["defaultCSE"] = defaultCSEDict
                record["defaultCSE"] = defaultCSEJSON
            }
            
            // PrivateCSE
            if userDefaults.bool(forKey: "usePrivateCSE") {
                let privateCSE = CSEDataManager.getCSEData(.privateCSE)
                let privateCSEDict = CSEDataManager.CSEDataToDictionary(privateCSE)
                let privateCSEJSON = CSEDataManager.jsonDictToString(privateCSEDict) ?? ""
                combinedDict["privateCSE"] = privateCSEDict
                record["privateCSE"] = privateCSEJSON
            }
            
            // QuickCSE
            if userDefaults.bool(forKey: "useQuickCSE") {
                let quickCSEs = CSEDataManager.getAllQuickCSEData()
                let quickCSEDict = CSEDataManager.CSEDataToDictionary(quickCSEs)
                let quickCSEJSON = CSEDataManager.jsonDictToString(quickCSEDict) ?? ""
                combinedDict["quickCSE"] = quickCSEDict
                record["quickCSE"] = quickCSEJSON
            }
            
            // Use Emoji Search
            let useEmojiSearch = userDefaults.bool(forKey: "useEmojiSearch")
            combinedDict["useEmojiSearch"] = useEmojiSearch
            record["useEmojiSearch"] = useEmojiSearch
            
            // Quick Search Settings
            let QuickSearchSettings_keywordOnly = userDefaults.bool(forKey: "QuickSearchSettings_keywordOnly")
            combinedDict["QuickSearchSettings_keywordOnly"] = QuickSearchSettings_keywordOnly
            record["QuickSearchSettings_keywordOnly"] = QuickSearchSettings_keywordOnly
            
            let QuickSearchSettings_keywordPos = userDefaults.string(forKey: "QuickSearchSettings_keywordPos") ?? QuickSearchKeywordPos.default.rawValue
            combinedDict["QuickSearchSettings_keywordPos"] = QuickSearchSettings_keywordPos
            record["QuickSearchSettings_keywordPos"] = QuickSearchSettings_keywordPos
            
            // Gen hash
            let currentRecordHash = generateHash(from: CSEDataManager.jsonDictToString(combinedDict) ?? "")
            print("Current record hash: \(currentRecordHash.base64EncodedString())")
            
            // Compare with last uploaded hash (unless forced)
            if !mustUpload {
                let lastRecordHash = userDefaults.data(forKey: "cloudkit_lastRecordHash") ?? Data()
                guard currentRecordHash != lastRecordHash else {
                    print("No changes detected, skipping CloudKit upload.")
                    DispatchQueue.main.async {
                        self.currentStatus = .skipped
                        self.error = nil
                    }
                    return
                }
            }
            
            // Save record
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.savePolicy = .allKeys
            
            // Set completion handler to save the record data after successful upload
            operation.modifyRecordsResultBlock = { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        // Save the current record hash to UserDefaults for future comparison
                        self.userDefaults.set(currentRecordHash, forKey: "cloudkit_lastRecordHash")
                        self.error = nil
                        self.currentStatus = .success
                    case .failure(let error):
                        self.error = error
                        self.currentStatus = .failure
                    }
                }
            }
            
            database.add(operation)
        }
    }
    
    // Generate SHA256 hash from string
    private func generateHash(from string: String) -> Data {
        let data = Data(string.utf8)
        return Data(SHA256.hash(data: data))
    }
    
    // Fetch CSEs from all devices
    func fetchAll() {
        // Reset
        currentOperation = .fetchAll
        currentStatus = .inProgress
        error = nil
        self.allCSEs.removeAll()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            
            // Fetch records
            let query = CKQuery(recordType: "DeviceCSEs", predicate: NSPredicate(value: true))
            let sortDescriptor = NSSortDescriptor(key: "modificationDate", ascending: false)
            query.sortDescriptors = [sortDescriptor]
            
            let operation = CKQueryOperation(query: query)
            
            // Collect records
            operation.recordMatchedBlock = { (recordID: CKRecord.ID, result: Result<CKRecord, Error>) in
                switch result {
                case .success(let record):
                    let fetchedRecord = CSEDataManager.DeviceCSEs(
                        id: record.recordID,
                        version: record["version"] as? String ?? "",
                        modificationDate: record.modificationDate,
                        deviceName: record["deviceName"] as? String ?? "",
                        defaultCSE: record["defaultCSE"] as? String ?? "",
                        privateCSE: record["privateCSE"] as? String ?? "",
                        quickCSE: record["quickCSE"] as? String ?? "",
                        useEmojiSearch: record["useEmojiSearch"] as? Bool ?? false,
                        QuickSearchSettings_keywordOnly: record["QuickSearchSettings_keywordOnly"] as? Bool ?? true,
                        QuickSearchSettings_keywordPos: record["QuickSearchSettings_keywordPos"] as? String ?? QuickSearchKeywordPos.default.rawValue
                    )
                    DispatchQueue.main.async {
                        self.error = nil
                        self.allCSEs.append(fetchedRecord)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.error = error
                        self.currentStatus = .failure
                    }
                }
            }
            
            // Completion
            operation.queryResultBlock = { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        if self.currentStatus != .failure {
                            self.currentStatus = .success
                        }
                    case .failure(let error):
                        self.error = error
                        self.currentStatus = .failure
                    }
                }
            }
            
            database.add(operation)
        }
    }
    
    // Delete record
    func delete(recordID: CKRecord.ID) {
        currentOperation = .delete
        currentStatus = .inProgress
        error = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            
            let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [recordID])
            operation.modifyRecordsResultBlock = { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.allCSEs.removeAll { $0.id == recordID }
                        self.error = nil
                        self.currentStatus = .success
                    case .failure(let error):
                        self.error = error
                        self.currentStatus = .failure
                    }
                }
            }
            database.add(operation)
        }
    }
    
    func exportAllData() {
        currentOperation = .export
        currentStatus = .inProgress
        error = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            
            let query = CKQuery(recordType: "DeviceCSEs", predicate: NSPredicate(value: true))
            query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]
            
            let operation = CKQueryOperation(query: query)
            var recordsArray: [[String: Any]] = []
            
            operation.recordMatchedBlock = { _, result in
                guard case .success(let record) = result else { return }
                var dict: [String: Any] = [:]
                // Metadata
                dict["recordName"] = record.recordID.recordName
                dict["recordType"] = record.recordType
                dict["modificationDate"] = ISO8601DateFormatter().string(from: record.modificationDate ?? Date())
                // All custom fields -> String(describing: value) for raw dump
                for key in record.allKeys() {
                    if let value = record[key] { // CKRecordValue
                        dict[key] = String(describing: value)
                    }
                }
                recordsArray.append(dict)
            }
            
            operation.queryResultBlock = { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        let root: [String: Any] = [
                            "exportDate": ISO8601DateFormatter().string(from: Date()),
                            "records": recordsArray
                        ]
                        if let data = try? JSONSerialization.data(withJSONObject: root, options: [.sortedKeys]),
                           let json = String(data: data, encoding: .utf8) {
                            NotificationCenter.default.post(name: NSNotification.Name("CloudKitAllDataExported"), object: json)
                        }
                        DispatchQueue.main.async {
                            self.error = nil
                            self.currentStatus = .success
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.error = error
                            self.currentStatus = .failure
                        }
                    }
                }
            }
            database.add(operation)
        }
    }
}
