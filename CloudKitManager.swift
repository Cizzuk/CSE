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
    
    enum uploadStatus: Equatable {
        case idle
        case skipped
        case uploading
        case success
        case failure
    }
    
    @Published var cloudKitAvailability: CKAccountStatus?
    @Published var allCSEs: [CSEDataManager.DeviceCSEs] = [] // All data from iCloud
    @Published var error: Error? // Error message
    @Published var isLoading: Bool = false // Indicates if the CloudKit is loading
    @Published var isLocked: Bool = false // If the current view is locked
    @Published var uploadStatus: uploadStatus = .idle
    
    init() {
        checkCloudKitAvailability()
    }
    
    // Check CloudKit availability
    private func checkCloudKitAvailability() {
        CKContainer(identifier: "iCloud.net.cizzuk.cse").accountStatus { status, error in
            DispatchQueue.main.async {
                self.cloudKitAvailability = status
                if let error = error {
                    self.error = error
                    print("Error checking iCloud availability: \(error)")
                }
            }
        }
    }
    
    // Create device name
    func createDeviceName() -> String {
        #if macOS
        return "Mac Catalyst / " + UIDevice.current.systemName + " " + UIDevice.current.systemVersion
        #else
        return UIDevice.current.name + " / " + UIDevice.current.systemName + " " + UIDevice.current.systemVersion
        #endif
    }
    
    // Upload CSEs
    func saveAll(mustUpload: Bool = false) {
        // Check if iCloud is available
        guard cloudKitAvailability == .available else {
            print("CloudKit is not available, skipping upload")
            self.uploadStatus = .skipped
            return
        }
        
        // Check if upload is disabled
        guard mustUpload || userDefaults.bool(forKey: "adv_icloud_disableUploadCSE") else {
            self.uploadStatus = .skipped
            return
        }
        self.uploadStatus = .uploading
        
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
        
        // Gen hash
        let currentRecordHash = generateHash(from: CSEDataManager.jsonDictToString(combinedDict) ?? "")
        print("Current record hash: \(currentRecordHash.base64EncodedString())")
        
        // Check if the record is the same as the last uploaded
        if !mustUpload {
            let lastRecordHash = userDefaults.data(forKey: "cloudkit_lastRecordHash") ?? Data()
            guard currentRecordHash != lastRecordHash else {
                // Same record, skip upload
                print("No changes detected, skipping CloudKit upload.")
                self.uploadStatus = .skipped
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
                    print("CloudKit upload successful")
                    self.uploadStatus = .success
                case .failure(let error):
                    print("CloudKit upload failed: \(error)")
                    self.uploadStatus = .failure
                    
                }
            }
        }
        
        database.add(operation)
    }
    
    // Generate SHA256 hash from string
    private func generateHash(from string: String) -> Data {
        let data = Data(string.utf8)
        let hash = SHA256.hash(data: data)
        return Data(hash)
    }
    
    // fetch CSEs from other devices
    func fetchAll() {
        // Reset
        isLoading = true
        self.allCSEs.removeAll()
        
        // Fetch records
        let query = CKQuery(recordType: "DeviceCSEs", predicate: NSPredicate(value: true))
        let sortDescriptor = NSSortDescriptor(key: "modificationDate", ascending: false)
        query.sortDescriptors = [sortDescriptor]
        
        let operation = CKQueryOperation(query: query)
        
        // Save record or get error
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
                    useEmojiSearch: record["useEmojiSearch"] as? Bool ?? false
                )
                self.error = nil
                self.allCSEs.append(fetchedRecord)
            case .failure(let error):
                self.error = error
            }
        }
        
        // Loading handler
        operation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.isLoading = false
                case .failure(let error):
                    self.error = error
                    self.isLoading = false
                }
            }
        }

        database.add(operation)
    }
    
    // Delete record
    func delete(recordID: CKRecord.ID) {
        isLocked = true
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [recordID])
        operation.modifyRecordsResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.isLocked = false
                    self.allCSEs.removeAll { $0.id == recordID }
                case .failure(let error):
                    self.error = error
                    self.isLocked = false
                }
            }
        }
        database.add(operation)
    }
}
