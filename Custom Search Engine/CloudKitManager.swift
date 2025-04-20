//
//  CloudKitManager.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/04/20.
//

import CloudKit
import Combine
import UIKit

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
    
    @Published var allCSEs: [DeviceCSEs] = []
    @Published var error: Error?
    @Published var isLoading: Bool = false
    
    // Upload CSEs
    func saveAll(mustUpload: Bool = false) {
        let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")!
        
        if !mustUpload && userDefaults.bool(forKey: "adv_icloud_disableUploadCSE") {
            return
        }
        
        let defaultCSE: [String: Any] = userDefaults.dictionary(forKey: "defaultCSE") ?? [:]
        let privateCSE: [String: Any] = userDefaults.dictionary(forKey: "privateCSE") ?? [:]
        let quickCSE: [String: [String: Any]] = userDefaults.dictionary(forKey: "quickCSE") as? [String: [String: Any]] ?? [:]
        
        let defaultCSEJSON = cseDataToJSONString(dictionary: defaultCSE)
        let privateCSEJSON = cseDataToJSONString(dictionary: privateCSE)
        let quickCSEJSON = cseDataToJSONString(dictionary: quickCSE)
        
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let recordID = CKRecord.ID(recordName: deviceID)
        let record = CKRecord(recordType: "DeviceCSEs", recordID: recordID)
        
        // macOS Catalyst support
        #if macOS
        let deviceName = "Mac Catalyst / " + UIDevice.current.systemName + " " + UIDevice.current.systemVersion
        #else
        let deviceName = UIDevice.current.name + " / " + UIDevice.current.systemName + " " + UIDevice.current.systemVersion
        #endif
        
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
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .allKeys
        
        database.add(operation)
    }
    
    func cseDataToJSONString(dictionary: Any) -> String {
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
        
        let query = CKQuery(recordType: "DeviceCSEs", predicate: NSPredicate(value: true))
        let sortDescriptor = NSSortDescriptor(key: "modificationDate", ascending: false)
        query.sortDescriptors = [sortDescriptor]
        
        let operation = CKQueryOperation(query: query)
        
        // Fetch records
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
        
        // Completion block
        operation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.isLoading = false
                    print (self.allCSEs)
                case .failure(let error):
                    self.error = error
                    self.isLoading = false
                }
            }
        }

        database.add(operation)
    }
    
    func delete(recordID: CKRecord.ID) {
        database.delete(withRecordID: recordID) { deletedID, err in
            DispatchQueue.main.async {
                if let err = err {
                    self.error = err
                } else if let deletedID = deletedID {
                    self.allCSEs.removeAll { $0.id == deletedID }
                }
            }
        }
    }
}
