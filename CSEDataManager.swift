//
//  CSEDataManager.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/05/25.
//

import Foundation
import CloudKit

class CSEDataManager {
    static let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")!
    
    enum CSEType: String {
        case defaultCSE, privateCSE, quickCSE
    }
    
    // Structure of a CSE data
    struct CSEData: Encodable {
        var name: String = ""
        var keyword: String = ""
        var url: String = ""
        var post: [[String: String]] = []
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
    
    class func getCSEData(_ type: CSEType = .defaultCSE, id: String? = nil) -> CSEData {
        let cseData = userDefaults.dictionary(forKey: type.rawValue) ?? [:]
        switch type {
        case .defaultCSE, .privateCSE:
            return parseCSEData(cseData)
        case .quickCSE:
            guard let id = id,
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
    
    class func parseCSEData(_ data: [String: Any], id: String? = nil) -> CSEData {
        var parsedData = CSEData()
        if let name = data["name"] as? String {
            parsedData.name = name
        }
        if let keyword = id {
            parsedData.keyword = keyword
        }
        if let url = data["url"] as? String {
            parsedData.url = url
        }
        if let disablePercentEncoding = data["disablePercentEncoding"] as? Bool {
            parsedData.disablePercentEncoding = disablePercentEncoding
        }
        if let maxQueryLength = data["maxQueryLength"] as? Int {
            parsedData.maxQueryLength = maxQueryLength
        }
        if let postEntries = data["post"] as? [[String: String]] {
            parsedData.post = cleanPostData(postEntries)
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
    
    class func QuickCSEDataToDictionary(_ data: [String: CSEData]) -> [String: Any] {
        // Convert QuickCSE data to Dictionary
        var quickCSEDict: [String: Any] = [:]
        for (key, value) in data {
            quickCSEDict[key] = CSEDataToDictionary(value)
        }
        return quickCSEDict
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
    
    enum saveCSEDataError: Error {
        case keyBlank
        case urlBlank
        case keyUsed
    }
    
    class func saveCSEData(_ data: CSEData, _ type: CSEType = .defaultCSE, originalID: String? = nil) throws {
        var cseData = data
        
        // Normalize Safari search engine URLs
        let replacements = [
            "https://google.com": "https://www.google.com",
            "https://bing.com": "https://www.bing.com",
            "https://www.duckduckgo.com": "https://duckduckgo.com",
            "https://ecosia.com": "https://www.ecosia.com",
            "https://baidu.com": "https://www.baidu.com"
        ]
        for (original, replacement) in replacements {
            if cseData.url.hasPrefix(original) {
                cseData.url = cseData.url.replacingOccurrences(of: original, with: replacement)
                break
            }
        }
        
        // Clean up post data
        cseData.post = cleanPostData(cseData.post)
        
        // Save for Search Engine type
        switch type {
        case .defaultCSE, .privateCSE:
            cseData.keyword = "" // Default and Private CSEs do not have keywords
            cseData.name = "" // Default and Private CSEs do not have names
            userDefaults.set(CSEDataToDictionary(cseData), forKey: type.rawValue)
        case .quickCSE:
            // If Keyword is blank
            if cseData.keyword == "" {
                throw saveCSEDataError.keyBlank
            }
            // If URL is blank
            if cseData.url == "" {
                throw saveCSEDataError.urlBlank
            }
            // Get current QuickSEs Data
            var quickCSEData = getAllQuickCSEData()
            // If Keyword is changed
            if cseData.keyword != originalID {
                // If Keyword is free
                if quickCSEData[cseData.keyword] == nil {
                    if originalID != nil {
                        quickCSEData.removeValue(forKey: originalID!)
                    }
                } else {
                    throw saveCSEDataError.keyUsed
                }
            }
            // Replace this QuickSE
            quickCSEData.removeValue(forKey: cseData.keyword)
            quickCSEData[cseData.keyword] = cseData
            
            // Convert to Dictionary
            var quickCSEDataDict = QuickCSEDataToDictionary(quickCSEData)
            userDefaults.set(quickCSEDataDict, forKey: "quickCSE")
        }
        
        // Upload CSEData to iCloud
        CloudKitManager().saveAll()
    }
    
    class func deleteQuickCSE(_ id: String) {
        // Get current QuickSEs Data
        var quickCSEData = getAllQuickCSEData()
        // Remove this QuickSE
        quickCSEData.removeValue(forKey: id)
        // Convert to Dictionary
        var quickCSEDataDict = QuickCSEDataToDictionary(quickCSEData)
        userDefaults.set(quickCSEDataDict, forKey: "quickCSE")
    }
    
    class func cleanPostData(_ post: [[String: String]]) -> [[String: String]] {
        return post.filter { entry in
            if let key = entry["key"], let value = entry["value"] {
                return !key.isEmpty && !value.isEmpty
            }
            return false
        }
    }
    
}
