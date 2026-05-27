//
//  ImportBackupJSON.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2026/05/27.
//

import AppIntents

struct ImportBackupJSON: AppIntent {
    static var title: LocalizedStringResource = "Import Backup JSON"
    
    @Parameter(title: "JSON", default: "")
    var json: String

    func perform() async throws -> some IntentResult {
        try CSEDataManager.importDeviceCSEsFromJSON(json)
        return .result()
    }
}
