//
//  BackupView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/07/29.
//

import SwiftUI

struct BackupView: View {
    
    var body: some View {
        List {
            Section {
                Button(action: {
                    CloudKitManager().saveAll(mustUpload: true)
                }) {
                    HStack {
                        Image(systemName: "icloud.and.arrow.up")
                            .frame(width: 20.0)
                        Text("Backup to iCloud")
                    }
                }
                Button(action: {
                    // Show restore view sheet
                }) {
                    HStack {
                        Image(systemName: "icloud.and.arrow.down")
                            .frame(width: 20.0)
                        Text("Restore from iCloud")
                    }
                }
            }
            Section {
                Button(action: {
                    // CSEDataManager.exportDeviceCSEsAsJSON()
                }) {
                    HStack {
                        Image(systemName: "arrow.up.document")
                            .frame(width: 20.0)
                        Text("Export as JSON")
                    }
                }
                Button(action: {
                    // CSEDataManager.importDeviceCSEsFromJSON(jsonData)
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .frame(width: 20.0)
                        Text("Import from JSON")
                    }
                }
            }
        }
        .navigationTitle("Backup & Restore")
        .navigationBarTitleDisplayMode(.inline)
    }
}
