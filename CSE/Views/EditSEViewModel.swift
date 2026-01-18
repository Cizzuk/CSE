//
//  EditSEViewModel.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/12/10.
//

import SwiftUI
import Combine
#if !os(visionOS)
import WidgetKit
#endif

class EditSEViewModel: ObservableObject {
    enum SaveMode {
        case autosave
        case dismiss
    }

    let cseType: CSEDataManager.CSEType
    
    @Published var cseData: CSEDataManager.CSEData
    private var lastSavedCSEData: CSEDataManager.CSEData
    
    // For QuickCSE
    var quickCSEID: String?
    
    // Sheets
    @Published var isShowingPresets: Bool = false
    @Published var isShowingCloudImport: Bool = false
    @Published var isShowingPostData: Bool = false
    @Published var isShowingAdvancedSettings: Bool = false
    
    // Alert
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    
    init(type: CSEDataManager.CSEType, cseID: String? = nil) {
        self.cseType = type
        self.quickCSEID = cseID
        
        // Load Data
        let data: CSEDataManager.CSEData
        switch type {
        case .defaultCSE:
            data = CSEDataManager.getCSEData(.defaultCSE)
        case .privateCSE:
            data = CSEDataManager.getCSEData(.privateCSE)
        case .quickCSE:
            if let id = cseID {
                data = CSEDataManager.getCSEData(.quickCSE, id: id)
            } else {
                data = CSEDataManager.CSEData()
            }
        }
        self.cseData = data
        self.lastSavedCSEData = data
    }
    
    @discardableResult
    func saveData(_ mode: SaveMode) -> Bool {
        // Returns true if safe to dismiss (or autosaved), false if error/alert
        
        // Check if data changed
        if cseData == lastSavedCSEData && mode == .autosave {
            return true
        }
        
        // For QuickCSE "Add New", if empty and dismissing, just allow
        if cseType == .quickCSE && quickCSEID == nil && cseData == CSEDataManager.CSEData() && mode == .dismiss {
            return true
        }

        // Try to save data
        do {
            switch cseType {
            case .defaultCSE:
                CSEDataManager.saveCSEData(cseData, .defaultCSE, uploadCloud: mode == .dismiss)
            case .privateCSE:
                CSEDataManager.saveCSEData(cseData, .privateCSE, uploadCloud: mode == .dismiss)
            case .quickCSE:
                try CSEDataManager.saveCSEData(cseData, quickCSEID, uploadCloud: mode == .dismiss)
                if mode == .autosave {
                    quickCSEID = cseData.keyword
                }
            }
            lastSavedCSEData = cseData
            return true
        } catch let error as CSEDataManager.saveCSEDataError {
            if mode == .dismiss {
                alertTitle = error.errorDescription ?? String(localized: "An error occurred while loading or updating data")
                showAlert = true
                return false
            }
        } catch {
            if mode == .dismiss {
                alertTitle = String(localized: "An error occurred while loading or updating data")
                showAlert = true
                return false
            }
        }
        return true
    }
    
    // Control Center Reload
    func handleToggleChange(isOn: Bool, key: String) {
        #if !os(visionOS)
        DispatchQueue.global(qos: .background).async {
            if #available(iOS 18.0, macOS 26, *) {
                ControlCenter.shared.reloadControls(ofKind: key)
            }
        }
        #endif
    }
}
