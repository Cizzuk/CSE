//
//  BackupView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/07/29.
//

import SwiftUI
import UniformTypeIdentifiers

class BackupView {
    struct BackupView: View {
        @AppStorage("iCloudAutoBackup", store: userDefaults) private var iCloudAutoBackup: Bool = true
        @StateObject private var ck = CloudKitManager()
        @State private var showingRestoreSheet = false
        @State private var showingFileImport = false
        @State private var showingErrorAlert = false
        @State private var errorMessage = ""
        
        var body: some View {
            List {
                // JSON Export/Import Section
                Section {
                    Button(action: {
                        #if !os(visionOS)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        #endif
                        guard let jsonString = CSEDataManager.exportDeviceCSEsAsJSON() else {
                            #if !os(visionOS)
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            #endif
                            return
                        }
                        exportJSONFile(jsonString: jsonString, filePrefix: "CSE")
                    }) {
                        UITemplates.IconLabel(icon: "square.and.arrow.up", text: "Export as JSON")
                    }
                    Button(action: { showingFileImport = true }) {
                        UITemplates.IconLabel(icon: "square.and.arrow.down", text: "Import from JSON")
                    }
                }
                
                // CloudKit Section
                Group {
                    Section {
                        Button(action: {
                            #if !os(visionOS)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            #endif
                            ck.saveAll(mustUpload: true)
                        }) {
                            HStack {
                                UITemplates.IconLabel(icon: "icloud.and.arrow.up", text: "Backup to iCloud")
                                Spacer()
                                if isUploading {
                                    ProgressView()
                                } else if uploadFailed {
                                    Image(systemName: "xmark")
                                } else if uploadSucceeded {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .disabled(isUploading)
                        .onChange(of: ck.currentStatus) { status in
                            guard ck.currentOperation == .upload else { return }
                            if status == .success {
                                #if !os(visionOS)
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                #endif
                            } else if status == .failure {
                                #if !os(visionOS)
                                UINotificationFeedbackGenerator().notificationOccurred(.error)
                                #endif
                            }
                        }
                        
                        Button(action: { showingRestoreSheet = true }) {
                            UITemplates.IconLabel(icon: "icloud.and.arrow.down", text: "Restore from iCloud")
                        }
                    }
                    
                    Section {
                        Toggle(isOn: $iCloudAutoBackup, label: {
                            Text("Auto Backup to iCloud")
                        })
                        Button(action: {
                            #if !os(visionOS)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            #endif
                            ck.exportAllData()
                        }) {
                            Text("Export All data from iCloud")
                        }
                    } footer: { Text("You can delete all data stored in iCloud from the iCloud settings.") }
                }
                .disabled(ck.cloudKitAvailability != .available || isLocked)
            }
            .navigationTitle("Backup & Restore")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingRestoreSheet) {
                CloudPicker.CloudPickerView(onRestore: nil)
            }
            .alert(errorMessage, isPresented: $showingErrorAlert, actions: {})
            .task { ck.checkCloudKitAvailability() }
            .onReceive(ck.$error) { error in
                guard let error else { return }
                errorMessage = error.localizedDescription
                showingErrorAlert = true
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("CloudKitAllDataExported"))) { note in
                if let jsonString = note.object as? String {
                    exportJSONFile(jsonString: jsonString, filePrefix: "CSE-RequestData")
                }
            }
            .fileImporter(
                isPresented: $showingFileImport,
                allowedContentTypes: [UTType.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let files):
                    guard let fileURL = files.first else { return }
                    importJSONFile(from: fileURL, onError: { error in
                        errorMessage = error
                        showingErrorAlert = true
                    })
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                }
            }
        }

        private var isUploading: Bool {
            ck.currentOperation == .upload && ck.currentStatus == .inProgress
        }

        private var uploadFailed: Bool {
            ck.currentOperation == .upload && ck.currentStatus == .failure
        }

        private var uploadSucceeded: Bool {
            ck.currentOperation == .upload && ck.currentStatus == .success
        }

        private var isLocked: Bool {
            ck.currentStatus == .inProgress && (ck.currentOperation == .export || ck.currentOperation == .delete)
        }
        
        // MARK: - Export JSON File

        private func exportJSONFile(jsonString: String, filePrefix: String) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let fileName = "\(filePrefix)-\(formatter.string(from: Date())).json"
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            // Write JSON string to file
            do {
                try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                #if !os(visionOS)
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                #endif
                return
            }
            
            #if os(visionOS)
            // if visionOS, use file
            let documentPicker = UIDocumentPickerViewController(forExporting: [fileURL], asCopy: true)
            documentPicker.modalPresentationStyle = .formSheet
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(documentPicker, animated: true, completion: nil)
            }
            #elseif targetEnvironment(macCatalyst)
            // if macOS, use finder
            let documentPicker = UIDocumentPickerViewController(forExporting: [fileURL], asCopy: true)
            documentPicker.modalPresentationStyle = .formSheet
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(documentPicker, animated: true, completion: nil)
            }
            #else
            // if ios, use share sheet
            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityViewController, animated: true, completion: nil)
            }
            #endif
        }
    }
    
    // MARK: - Import JSON File
    
    // Shared JSON import functionality for Tutorial and BackupView
    static func importJSONFile(from url: URL, onSuccess: @escaping () -> Void = {}, onError: @escaping (String) -> Void = { _ in }) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let jsonString = try String(contentsOf: url)
            try CSEDataManager.importDeviceCSEsFromJSON(jsonString)
            
            onSuccess()
            #if !os(visionOS)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            #endif
        } catch {
            onError(error.localizedDescription)
            #if !os(visionOS)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            #endif
        }
    }
}
