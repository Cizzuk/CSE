//
//  BackupView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/07/29.
//

import SwiftUI

struct BackupView: View {
    @StateObject private var ck = CloudKitManager()
    
    var body: some View {
        List {
            Section {
                Button(action: {
                    let impactFeedbacker = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbacker.prepare()
                    impactFeedbacker.impactOccurred()
                    ck.saveAll(mustUpload: true)
                }) {
                    HStack {
                        Image(systemName: "icloud.and.arrow.up")
                            .frame(width: 20.0)
                        Text("Backup to iCloud")
                        if ck.uploadStatus == .uploading {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                .disabled(ck.uploadStatus == .uploading)
                .onChange(of: ck.uploadStatus) { uploadStatus in
                    if uploadStatus == .success {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
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
