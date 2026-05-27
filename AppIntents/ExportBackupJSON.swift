//
//  ExportBackupJSON.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2026/05/27.
//

import AppIntents

struct ExportBackupJSON: AppIntent {
    static var title: LocalizedStringResource = "Export Backup JSON"

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        if let backupJSON = CSEDataManager.exportDeviceCSEsAsJSON() {
            return .result(value: backupJSON)
        } else {
            return .result(value: "")
        }
    }
}
