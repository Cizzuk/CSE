//
//  ExportBackupJSON.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2026/05/27.
//

import AppIntents

struct ExportBackupJSON: AppIntent {
    static var title: LocalizedStringResource = "Export Backup JSON"
    
    enum ExportBackupJSONError: Error {
        case exportFailed
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        if let backupJSON = CSEDataManager.exportDeviceCSEsAsJSON() {
            return .result(value: backupJSON)
        } else {
            throw ExportBackupJSONError.exportFailed
        }
    }
}
