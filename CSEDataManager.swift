//
//  CSEDataManager.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/05/25.
//

import Foundation
import CloudKit
import AppIntents
#if !os(visionOS)
import WidgetKit
#endif

class CSEDataManager {
    static let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")!
    static let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    enum CSEType: String, AppEnum {
        case defaultCSE
        case privateCSE
        case quickCSE
        
        static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Search Engine Type")
        static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
            .defaultCSE: "Default Search Engine",
            .privateCSE: "Private Search Engine",
            .quickCSE: "Quick Search Engine"
        ]
    }
    
    // Structure of a CSE data
    struct CSEData: Encodable, Equatable {
        var name: String = ""
        var keyword: String = ""
        var url: String = ""
        var post: [[String: String]] = []
        var disablePercentEncoding: Bool = false
        var maxQueryLength: Int? = nil
    }
    
    // Structure of a single device's CSE data for iCloud
    struct DeviceCSEs: Identifiable, Hashable {
        let id: CKRecord.ID
        let version: String
        let modificationDate: Date?
        let deviceName: String
        let defaultCSE: String
        let privateCSE: String
        let quickCSE: String
        let useEmojiSearch: Bool
        
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
    
    class func checkQuickCSEExists(_ id: String) -> Bool {
        let quickCSEData = userDefaults.dictionary(forKey: "quickCSE") ?? [:]
        return quickCSEData.keys.contains(id)
    }
    
    class func parseCSEData(_ dict: [String: Any], id: String? = nil) -> CSEData {
        var data = CSEData()
        if let v = dict["name"] as? String { data.name = v }
        if let v = id { data.keyword = v }
        if let v = dict["url"] as? String { data.url = v }
        if let v = dict["disablePercentEncoding"] as? Bool { data.disablePercentEncoding = v }
        if let v = dict["maxQueryLength"] as? Int, v >= 0 {
            data.maxQueryLength = v
        } else {
            data.maxQueryLength = nil
        }
        if let v = dict["post"] as? [[String: String]] { data.post = cleanPostData(v) }
            
        return data
    }
    
    // for QuickCSEs
    class func parseCSEData(_ data: [String: [String: Any]]) -> [String: CSEDataManager.CSEData] {
        // Convert Dictionary to CSEData
        var parsedCSEs: [String: CSEData] = [:]
        for (key, value) in data {
            parsedCSEs[key] = parseCSEData(value, id: key)
        }
        return parsedCSEs
    }
    
    class func CSEDataToDictionary(_ data: CSEData) -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["name"] = data.name
        dict["keyword"] = data.keyword
        dict["url"] = data.url
        dict["disablePercentEncoding"] = data.disablePercentEncoding
        dict["maxQueryLength"] = data.maxQueryLength
        dict["post"] = data.post
        return dict
    }
    
    class func CSEDataToDictionary(_ data: [String: CSEData]) -> [String: [String: Any]] {
        // Convert QuickCSE data to Dictionary
        var quickCSEDict: [String: [String: Any]] = [:]
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
    
    enum saveCSEDataError: LocalizedError {
        case keyBlank
        case urlBlank
        case keyUsed
        
        var errorDescription: String? {
            switch self {
            case .keyBlank: return String(localized: "Keyword cannot be blank")
            case .urlBlank: return String(localized: "Search URL cannot be blank")
            case .keyUsed: return String(localized: "This keyword is already used in other")
            }
        }
    }
    
    class func saveCSEDataCommon(_ data: CSEData) -> CSEData {
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
        
        if cseData.maxQueryLength ?? -1 < 0 {
            cseData.maxQueryLength = nil // Default value for maxQueryLength
        }
        
        return cseData
    }
    
    class func saveCSEData(_ data: CSEData, _ type: CSEType = .defaultCSE, uploadCloud: Bool = true) {
        // QuickCSE fallback
        if type == .quickCSE {
            try? saveCSEData(data, nil, uploadCloud: uploadCloud)
            return
        }
        
        var cseData = saveCSEDataCommon(data)
        
        // Default and Private CSEs do not have keywords and names
        cseData.keyword = "" // Default and Private CSEs do not have keywords
        cseData.name = "" // Default and Private CSEs do not have names
        userDefaults.set(CSEDataToDictionary(cseData), forKey: type.rawValue)
        
        // Upload CSEData to iCloud
        if uploadCloud { CloudKitManager().saveAll() }
    }
    
    class func saveCSEData(_ data: CSEData, _ originalID: String?, replace: Bool = false, uploadCloud: Bool = true) throws {
        var cseData = saveCSEDataCommon(data)
        
        // If Keyword is blank
        if cseData.keyword.isEmpty { throw saveCSEDataError.keyBlank }
        // If URL is blank
        if cseData.url.isEmpty { throw saveCSEDataError.urlBlank }
        
        // Remove whitespace from keyword
        cseData.keyword = cseData.keyword.filter { !($0.isWhitespace || $0.isNewline) }
        
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
                if replace {
                    quickCSEData.removeValue(forKey: cseData.keyword)
                } else { throw saveCSEDataError.keyUsed }
            }
        }
        // Replace this QuickSE
        quickCSEData.removeValue(forKey: cseData.keyword)
        quickCSEData[cseData.keyword] = cseData
        
        // Convert to Dictionary
        let quickCSEDataDict = CSEDataToDictionary(quickCSEData)
        userDefaults.set(quickCSEDataDict, forKey: "quickCSE")
        
        // Upload CSEData to iCloud
        if uploadCloud { CloudKitManager().saveAll() }
    }
    
    class func replaceQuickCSEData(_ data: [String: CSEData]) {
        // Convert to Dictionary
        let quickCSEDataDict = CSEDataToDictionary(data)
        userDefaults.set(quickCSEDataDict, forKey: "quickCSE")
    }
    
    class func replaceQuickCSEData(_ data: [String: [String: Any]]) {
        userDefaults.set(data, forKey: "quickCSE")
    }
    
    class func deleteQuickCSE(_ id: String) {
        // Get current QuickSEs Data
        var quickCSEData = getAllQuickCSEData()
        // Remove this QuickSE
        quickCSEData.removeValue(forKey: id)
        // Convert to Dictionary
        let quickCSEDataDict = CSEDataToDictionary(quickCSEData)
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
    
    class func postDataToString(_ post: [[String: String]], join: String = "=", separator: String = "&") -> String {
        if post.isEmpty { return "" }
        
        // key=value&key=value&...
        let postData = post.map { entry in
            if let key = entry["key"], let value = entry["value"] {
                let encodedKey =
                (key.addingPercentEncoding(withAllowedCharacters: .alphanumerics.union(.init(charactersIn: "~-._"))) ?? key)
                    .replacingOccurrences(of: "%25s", with: "%s")
                let encodedValue =
                (value.addingPercentEncoding(withAllowedCharacters: .alphanumerics.union(.init(charactersIn: "~-._"))) ?? value)
                    .replacingOccurrences(of: "%25s", with: "%s")
                
                return "\(encodedKey)\(join)\(encodedValue)"
            }
            return ""
        }.filter { !$0.isEmpty }.joined(separator: separator)
        
        return postData
    }
    
    class func postDataToDictionary(_ post: String, join: String = "=", separator: String = "&") -> [[String: String]] {
        // Convert post data to Dictionary
        var postDataDict: [[String: String]] = []
        // [["key"="example", "value"="example"]] format
        
        // Split the post data by separator
        let entries = post.split(separator: separator).map { String($0) }
        for entry in entries {
            // Split each entry by join
            let components = entry.split(separator: join).map { String($0) }
            if components.count == 2 {
                let key = components[0].removingPercentEncoding ?? components[0]
                let value = components[1].removingPercentEncoding ?? components[1]
                postDataDict.append(["key": key, "value": value])
            }
        }
        
        return postDataDict
    }
    
    enum jsonError: LocalizedError {
        case parseError
        case validDataNotFound
        
        var errorDescription: String? {
            switch self {
            case .parseError: return String(localized: "Failed to parse JSON data")
            case .validDataNotFound: return String(localized: "Valid data not found in JSON")
            }
        }
    }
    
    class func exportDeviceCSEsAsJSON() -> String? {
        // Create JSON Dictionary
        var jsonDict: [String: Any] = [:]
        jsonDict["type"] = "net.cizzuk.cse.deviceCSEs"
        jsonDict["version"] = currentVersion
        
        // DefaultCSE
        if userDefaults.bool(forKey: "useDefaultCSE") {
            let defaultCSE = getCSEData(.defaultCSE)
            let defaultCSEDict = CSEDataToDictionary(defaultCSE)
            jsonDict["defaultCSE"] = defaultCSEDict
        }
        
        // PrivateCSE
        if userDefaults.bool(forKey: "usePrivateCSE") {
            let privateCSE = getCSEData(.privateCSE)
            let privateCSEDict = CSEDataToDictionary(privateCSE)
            jsonDict["privateCSE"] = privateCSEDict
        }
        
        // QuickCSE
        if userDefaults.bool(forKey: "useQuickCSE") {
            let quickCSEs = getAllQuickCSEData()
            let quickCSEDict = CSEDataToDictionary(quickCSEs)
            jsonDict["quickCSE"] = quickCSEDict
        }
        
        // Emoji Search
        jsonDict["useEmojiSearch"] = userDefaults.bool(forKey: "useEmojiSearch")
        
        // Convert Dictionary to JSON String
        return jsonDictToString(jsonDict)
    }
    
    class func importDeviceCSEsFromJSON(_ jsonString: String) throws {
        // Convert JSON string to Dictionary
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            throw jsonError.parseError
        }
        
        // Check JSON Data
        guard let type = jsonDict["type"] as? String, type == "net.cizzuk.cse.deviceCSEs" else {
            throw jsonError.validDataNotFound
        }
        
        // Extract and import CSEs
        let defaultCSEJSON = jsonDict["defaultCSE"] as? [String: Any] ?? [:]
        let privateCSEJSON = jsonDict["privateCSE"] as? [String: Any] ?? [:]
        let quickCSEJSON = jsonDict["quickCSE"] as? [String: [String: Any]] ?? [:]
        let useEmojiSearch = jsonDict["useEmojiSearch"] as? Bool ?? false
        
        // Convert JSON strings to CSEData
        let defaultCSE = parseCSEData(defaultCSEJSON)
        let privateCSE = parseCSEData(privateCSEJSON)
        let quickCSE = parseCSEData(quickCSEJSON)
        
        // Save CSEs
        saveCSEData(defaultCSE, .defaultCSE, uploadCloud: false)
        saveCSEData(privateCSE, .privateCSE, uploadCloud: false)
        replaceQuickCSEData(quickCSE)
        
        // Update Toggles
        userDefaults.set(!defaultCSE.url.isEmpty, forKey: "useDefaultCSE")
        userDefaults.set(!privateCSE.url.isEmpty, forKey: "usePrivateCSE")
        userDefaults.set(!quickCSE.isEmpty, forKey: "useQuickCSE")
        userDefaults.set(useEmojiSearch, forKey: "useEmojiSearch")
        
        // Update CC
        #if !os(visionOS)
        if #available(iOS 18.0, macOS 26, *) {
            ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.UseDefaultCSE")
            ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.UsePrivateCSE")
            ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.QuickSearch")
            ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.EmojiSearch")
        }
        #endif
    }
    
    class func importDeviceCSEs(from deviceCSE: DeviceCSEs) {
        // Parse device CSE data using existing function
        let (defaultCSE, privateCSE, quickCSE) = parseDeviceCSEs(deviceCSE)
        
        // Save CSEs
        saveCSEData(defaultCSE, .defaultCSE, uploadCloud: false)
        saveCSEData(privateCSE, .privateCSE, uploadCloud: false)
        replaceQuickCSEData(quickCSE)
        
        // Update Toggles
        userDefaults.set(!defaultCSE.url.isEmpty, forKey: "useDefaultCSE")
        userDefaults.set(!privateCSE.url.isEmpty, forKey: "usePrivateCSE")
        userDefaults.set(!quickCSE.isEmpty, forKey: "useQuickCSE")
        userDefaults.set(deviceCSE.useEmojiSearch, forKey: "useEmojiSearch")
        
        // Update CC
        #if !os(visionOS)
        if #available(iOS 18.0, macOS 26, *) {
            ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.UseDefaultCSE")
            ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.UsePrivateCSE")
            ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.QuickSearch")
            ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.EmojiSearch")
        }
        #endif
    }
    
    class func jsonDictToString(_ cseData: Any) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: cseData, options: [.sortedKeys]),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}
