//
//  CloudKitManager.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/04/20.
//

import CloudKit
import Combine
import UIKit

// Structure of a single device's CSE data
struct DeviceCSEs: Identifiable, Hashable {
    let id: CKRecord.ID
    let modificationDate: Date?
    let deviceName: String
    let defaultCSE: String
    let privateCSE: String
    let quickCSE: String
    
    static func == (lhs: DeviceCSEs, rhs: DeviceCSEs) -> Bool {
            return lhs.id.recordName == rhs.id.recordName
        }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id.recordName)
    }
}

final class CloudKitManager: ObservableObject {
    private let database: CKDatabase = CKContainer(identifier: "iCloud.net.cizzuk.cse").privateCloudDatabase
    
    @Published var allCSEs: [DeviceCSEs] = [] // All data from iCloud
    @Published var error: Error? // Error message
    @Published var isLoading: Bool = false // Indicates if the CloudKit is loading
    @Published var isLocked: Bool = false // If the current view is locked
    
    // Upload CSEs
    func saveAll(mustUpload: Bool = false) {
        // Check if upload is disabled
        if !mustUpload && userDefaults.bool(forKey: "adv_icloud_disableUploadCSE") {
            return
        }
        
        // Get userDefaults
        let defaultCSE: [String: Any] = CSEDataManager.getCSEData(cseType: .defaultCSE)
        let privateCSE: [String: Any] = CSEDataManager.getCSEData(cseType: .privateCSE)
        let quickCSE: [String: [String: Any]] = CSEDataManager.getAllQuickCSEData()
        
        // Convert to JSON string
        let defaultCSEJSON = cseDataToJSONString(dictionary: defaultCSE)
        let privateCSEJSON = cseDataToJSONString(dictionary: privateCSE)
        let quickCSEJSON = cseDataToJSONString(dictionary: quickCSE)
        
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let recordID = CKRecord.ID(recordName: deviceID)
        let record = CKRecord(recordType: "DeviceCSEs", recordID: recordID)
        
        // Create device name
        #if macOS
        let deviceName = "Mac Catalyst / " + UIDevice.current.systemName + " " + UIDevice.current.systemVersion
        #else
        let deviceName = UIDevice.current.name + " / " + UIDevice.current.systemName + " " + UIDevice.current.systemVersion
        #endif
        
        // Set record values
        record["deviceName"] = deviceName
        record["defaultCSE"] = defaultCSEJSON
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
        
        // Save record
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .allKeys
        
        database.add(operation)
    }
    
    // Convert dictionary to JSON string
    private func cseDataToJSONString(dictionary: Any) -> String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return ""
        }
        return jsonString
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
                let fetchedRecord = DeviceCSEs(
                    id: record.recordID,
                    modificationDate: record.modificationDate,
                    deviceName: record["deviceName"] as? String ?? "",
                    defaultCSE: record["defaultCSE"] as? String ?? "",
                    privateCSE: record["privateCSE"] as? String ?? "",
                    quickCSE: record["quickCSE"] as? String ?? ""
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
