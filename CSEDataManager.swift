//
//  CSEDataManager.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/05/25.
//

import Foundation
import CloudKit

class CSEDataManager {
    enum CSEType: String {
        case defaultCSE, privateCSE, quickCSE
    }
    
    // Structure of a CSE data
    struct CSEData {
        var name: String = ""
        var keyword: String = ""
        var url: String = ""
        var post: [[String: String]] = [[:]]
        var disablePercentEncoding: Bool = false
        var maxQueryLength: Int = -1
    }
    
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
        
    static let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")!
    
    class func getCSEData(_ cseType: CSEType = .defaultCSE, cseID: String? = nil) -> CSEData {
        let cseData = userDefaults.dictionary(forKey: cseType.rawValue) ?? [:]
        switch cseType {
        case .defaultCSE, .privateCSE:
            return parseCSEData(cseData)
        case .quickCSE:
            guard let id = cseID,
                  let quickDict = cseData as? [String: [String: Any]] else {
                return CSEData()
            }
            return parseCSEData(quickDict[id] ?? [:], id: id)
        }
    }
    
    class func getAllQuickCSEData() -> [String: CSEData] {
        let quickCSEData = userDefaults.dictionary(forKey: "quickCSE") ?? [:]
        var allQuickCSEs: [String: CSEData] = [:]
        for (key, value) in quickCSEData {
            if let cseDict = value as? [String: Any] {
                allQuickCSEs[key] = parseCSEData(cseDict, id: key)
            }
        }
        return allQuickCSEs
    }
    
    class func parseCSEData(_ dicData: [String: Any], id: String? = nil) -> CSEData {
        var parsedData = CSEData()
        if let name = dicData["name"] as? String {
            parsedData.name = name
        }
        if let keyword = id {
            parsedData.keyword = keyword
        }
        if let url = dicData["url"] as? String {
            parsedData.url = url
        }
        if let disablePercentEncoding = dicData["disablePercentEncoding"] as? Bool {
            parsedData.disablePercentEncoding = disablePercentEncoding
        }
        if let maxQueryLength = dicData["maxQueryLength"] as? Int {
            parsedData.maxQueryLength = maxQueryLength
        }
        if let postEntries = dicData["post"] as? [[String: String]] {
            parsedData.post = postEntries
        }
            
        return parsedData
    }
    
    class func CSEDataToDictionary(_ data: CSEData) -> [String: Any] {
        // Convert CSEData to Dictionary
        var cseDict: [String: Any] = [:]
        cseDict["name"] = data.name
        cseDict["keyword"] = data.keyword
        cseDict["url"] = data.url
        cseDict["disablePercentEncoding"] = data.disablePercentEncoding
        cseDict["maxQueryLength"] = data.maxQueryLength
        cseDict["post"] = data.post
        return cseDict
    }
    
    class func parseDeviceCSEs(_ ds: DeviceCSEs) -> (defaultCSE: CSEData, privateCSE: CSEData, quickCSE: [String: CSEData]) {
        // Convert JSON string to Dictionary
        let dicDefaultCSE = ds.defaultCSE.isEmpty ? [:] : (try? JSONSerialization.jsonObject(with: Data(ds.defaultCSE.utf8), options: [])) as? [String: Any] ?? [:]
        let dicPrivateCSE = ds.privateCSE.isEmpty ? [:] : (try? JSONSerialization.jsonObject(with: Data(ds.privateCSE.utf8), options: [])) as? [String: Any] ?? [:]
        let dicQuickCSE = ds.quickCSE.isEmpty ? [:] : (try? JSONSerialization.jsonObject(with: Data(ds.quickCSE.utf8), options: [])) as? [String: [String: Any]] ?? [:]
        
        // Parse CSE data
        let defaultCSE = parseCSEData(dicDefaultCSE)
        let privateCSE = parseCSEData(dicPrivateCSE)
        var quickCSE: [String: CSEData] = [:]
        for (key, value) in dicQuickCSE {
            quickCSE[key] = parseCSEData(value, id: key)
        }
        
        return (defaultCSE, privateCSE, quickCSE)
    }
    
//    class func saveCSEData(cseType: CSEType = .defaultCSE, cseData: CSEData) {
//        // Normalize Safari search engine URLs
//        let replacements = [
//            "https://google.com": "https://www.google.com",
//            "https://bing.com": "https://www.bing.com",
//            "https://www.duckduckgo.com": "https://duckduckgo.com",
//            "https://ecosia.com": "https://www.ecosia.com",
//            "https://baidu.com": "https://www.baidu.com"
//        ]
//        for (original, replacement) in replacements {
//            if cseURL.hasPrefix(original) {
//                cseURL = cseURL.replacingOccurrences(of: original, with: replacement)
//                break
//            }
//        }
//        
//        // POST Data
//        let postArray: [[String: String]] = postEntries
//            .map { ["key": $0.key, "value": $0.value] }
//            .filter { !$0["key"]!.isEmpty && !$0["value"]!.isEmpty }
//        
//        // Check maxQueryLengthToggle is enabled
//        let fixedMaxQueryLength: Int = maxQueryLengthToggle ? maxQueryLength ?? -1 : -1
//        
//        // Create temporary data
//        var tmpCSEData: [String: Any] = [
//            "url": cseURL,
//            "disablePercentEncoding": disablePercentEncoding,
//            "maxQueryLength": fixedMaxQueryLength,
//            "post": postArray
//        ]
//        
//        // Save for Search Engine type
//        switch cseType {
//        case "default":
//            userDefaults.set(tmpCSEData, forKey: "defaultCSE")
//        case "private":
//            userDefaults.set(tmpCSEData, forKey: "privateCSE")
//        case "quick":
//            // If Keyword is blank
//            if quickID == "" {
//                showKeyBlankAlert = true
//                return
//            }
//            // If URL is blank
//            if cseURL == "" {
//                showURLBlankAlert = true
//                return
//            }
//            // Get current QuickSEs Data
//            var quickCSEData = userDefaults.dictionary(forKey: "quickCSE") ?? [:]
//            // If Keyword is changed
//            if cseID != quickID {
//                // If Keyword is free
//                if quickCSEData[quickID] == nil {
//                    quickCSEData.removeValue(forKey: cseID)
//                    cseID = quickID
//                } else {
//                    showKeyUsedAlert = true
//                    return
//                }
//            }
//            // Replace this QuickSE
//            quickCSEData.removeValue(forKey: quickID)
//            tmpCSEData["name"] = cseName
//            quickCSEData[quickID] = tmpCSEData
//            userDefaults.set(quickCSEData, forKey: "quickCSE")
//        default: // If unknown CSE type
//            showFailAlert = true
//            dismiss()
//            return
//        }
//        
//        // Upload CSEData to iCloud
//        CloudKitManager().saveAll()
//        
//        dismiss()
//    }
    
}
