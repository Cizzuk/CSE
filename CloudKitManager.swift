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
    
    @Published var allCSEs: [CSEDataManager.DeviceCSEs] = [] // All data from iCloud
    @Published var error: Error? // Error message
    @Published var isLoading: Bool = false // Indicates if the CloudKit is loading
    @Published var isLocked: Bool = false // If the current view is locked
    
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
        // Check if upload is disabled
        if !mustUpload && userDefaults.bool(forKey: "adv_icloud_disableUploadCSE") {
            return
        }
        
        // Get userDefaults
        let defaultCSE: CSEDataManager.CSEData = CSEDataManager.getCSEData(.defaultCSE)
        let privateCSE: CSEDataManager.CSEData = CSEDataManager.getCSEData(.privateCSE)
        let quickCSE: [String: CSEDataManager.CSEData] = CSEDataManager.getAllQuickCSEData()
        let useEmojiSearch: Bool = userDefaults.bool(forKey: "useEmojiSearch")
        
        // Convert CSE data to dictionary
        let defaultCSEDict = CSEDataManager.CSEDataToDictionary(defaultCSE)
        let privateCSEDict = CSEDataManager.CSEDataToDictionary(privateCSE)
        let quickCSEDict = CSEDataManager.CSEDataToDictionary(quickCSE)
        
        // Convert to JSON string
        let defaultCSEJSON: String = CSEDataManager.jsonDictToString(defaultCSEDict) ?? ""
        let privateCSEJSON: String = CSEDataManager.jsonDictToString(privateCSEDict) ?? ""
        let quickCSEJSON: String = CSEDataManager.jsonDictToString(quickCSEDict) ?? ""
        
        let combinedString = "\(defaultCSEJSON)|\(privateCSEJSON)|\(quickCSEJSON)|\(useEmojiSearch)"
        let currentRecordHash = generateHash(from: combinedString)
        print("Current record hash: \(currentRecordHash)")
        
        // Check if the record is the same as the last uploaded
        if !mustUpload {
            let lastUploadedRecordHash = userDefaults.string(forKey: "lastUploadedCloudKitRecordHash") ?? ""
            if currentRecordHash == lastUploadedRecordHash {
                // Same record, skip upload
                print("No changes detected, skipping CloudKit upload.")
                return
            }
        }
        
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let recordID = CKRecord.ID(recordName: deviceID)
        let record = CKRecord(recordType: "DeviceCSEs", recordID: recordID)
        
        // Set record values
        record["deviceName"] = createDeviceName()
        if userDefaults.bool(forKey: "useDefaultCSE") {
            record["defaultCSE"] = defaultCSEJSON
        } else {
            record["defaultCSE"] = ""
        }
        if userDefaults.bool(forKey: "usePrivateCSE") {
            record["privateCSE"] = privateCSEJSON
        } else {
            record["privateCSE"] = ""
        }
        if userDefaults.bool(forKey: "useQuickCSE") {
            record["quickCSE"] = quickCSEJSON
        } else {
            record["quickCSE"] = ""
        }
        record["useEmojiSearch"] = useEmojiSearch
        
        // Save record
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .allKeys
        
        // Set completion handler to save the record data after successful upload
        operation.modifyRecordsResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Save the current record hash to UserDefaults for future comparison
                    self.userDefaults.set(currentRecordHash, forKey: "lastUploadedCloudKitRecordHash")
                    print("CloudKit upload successful", currentRecordHash)
                case .failure(let error):
                    print("CloudKit upload failed: \(error)")
                }
            }
        }
        
        database.add(operation)
    }
    
    // Generate SHA256 hash from string
    private func generateHash(from string: String) -> String {
        let data = Data(string.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
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
