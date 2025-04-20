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
    
    // Upload CSEs
    func saveAll(mustUpload: Bool = false) {
        let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")!
        
        if !mustUpload {
            if userDefaults.bool(forKey: "adv_icloud_disableUploadCSE") {
                return
            }
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
        
        let deviceName = UIDevice.current.name + " / " + UIDevice.current.systemName + " " + UIDevice.current.systemVersion
        
        record["deviceName"] = deviceName
        record["defaultCSE"] = defaultCSEJSON
        record["privateCSE"] = privateCSEJSON
        record["quickCSE"] = quickCSEJSON
        
        let op = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        op.savePolicy = .allKeys
        op.modifyRecordsCompletionBlock = { savedRecords, _, opError in
            DispatchQueue.main.async {
                if let err = opError {
                    self.error = err
                    return
                }

                if let rec = savedRecords?.first {
                    let ds = DeviceCSEs(
                        id: rec.recordID,
                        deviceName: rec["deviceName"] as! String,
                        defaultCSE: rec["defaultCSE"] as! String,
                        privateCSE: rec["privateCSE"] as! String,
                        quickCSE: rec["quickCSE"] as! String
                    )
                    if let idx = self.allCSEs.firstIndex(of: ds) {
                        self.allCSEs[idx] = ds
                    } else {
                        self.allCSEs.append(ds)
                    }
                }
            }
        }
        
        self.database.add(op)
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
        let query = CKQuery(recordType: "DeviceCSEs", predicate: NSPredicate(value: true))
        let op = CKQueryOperation(query: query)
        var results: [DeviceCSEs] = []
        
        op.recordFetchedBlock = { record in
            let ds = DeviceCSEs(
                id: record.recordID,
                deviceName: record["deviceName"] as! String,
                defaultCSE: record["defaultCSE"] as! String,
                privateCSE: record["privateCSE"] as! String,
                quickCSE: record["quickCSE"] as! String
            )
            results.append(ds)
        }
        op.queryCompletionBlock = { _, err in
            DispatchQueue.main.async {
                if let err = err {
                    self.error = err
                } else {
                    self.allCSEs = results
                }
            }
        }
        database.add(op)
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
