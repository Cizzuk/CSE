//
//  CSEDataManager.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/05/25.
//

import Foundation

class CSEDataManager {
    enum CSEType: String {
        case defaultCSE, privateCSE, quickCSE
    }
    
    static let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")!
    
    class func getCSEData(cseType: CSEType = .defaultCSE, cseID: String? = nil) -> [String: Any] {
        let cseData = userDefaults.dictionary(forKey: cseType.rawValue) ?? [:]
        switch cseType {
        case .defaultCSE, .privateCSE:
            return cseData
        case .quickCSE:
            guard let id = cseID,
                  let quickDict = cseData as? [String: [String: Any]] else {
                return [:]
            }
            return quickDict[id] ?? [:]
        }
    }
    
    class func getAllQuickCSEData() -> [String: [String: Any]] {
        return userDefaults.dictionary(forKey: CSEType.quickCSE.rawValue)
        as? [String: [String: Any]] ?? [:]
    }
    
}
