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
                        UITemplates.iconButton(icon: "square.and.arrow.up", text: "Export as JSON")
                    }
                    Button(action: {
                        showingFileImport = true
                    }) {
                        UITemplates.iconButton(icon: "square.and.arrow.down", text: "Import from JSON")
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
                                UITemplates.iconButton(icon: "icloud.and.arrow.up", text: "Backup to iCloud")
                                Spacer()
                                if ck.uploadStatus == .uploading {
                                    ProgressView()
                                } else if ck.uploadStatus == .failure {
                                    Image(systemName: "xmark")
                                } else if ck.uploadStatus == .success {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .disabled(ck.uploadStatus == .uploading)
                        .onChange(of: ck.uploadStatus) { uploadStatus in
                            if uploadStatus == .success {
                                #if !os(visionOS)
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                #endif
                            } else if uploadStatus == .failure {
                                #if !os(visionOS)
                                UINotificationFeedbackGenerator().notificationOccurred(.error)
                                #endif
                            }
                        }
                        
                        Button(action: {
                            showingRestoreSheet = true
                        }) {
                            UITemplates.iconButton(icon: "icloud.and.arrow.down", text: "Restore from iCloud")
                        }
                    }
                    
                    Section {
                        Button(action: {
                            #if !os(visionOS)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            #endif
                            ck.exportAllData()
                        }) {
                            UITemplates.iconButton(icon: "icloud", text: "Export All data from iCloud")
                        }
                    } footer: {
                        Text("You can delete all data stored in iCloud from the iCloud settings.")
                    }
                }
                .disabled(ck.cloudKitAvailability != .available || ck.isLocked)
            }
            .navigationTitle("Backup & Restore")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingRestoreSheet) {
                CloudRestoreView()
            }
            .alert(errorMessage, isPresented: $showingErrorAlert, actions: {})
            .task {
                ck.checkCloudKitAvailability()
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
    
    // CloudKit restore view for both BackupView and Tutorial
    struct CloudRestoreView: View {
        @StateObject private var ck = CloudKitManager()
        @State private var selected: String? = nil
        @Environment(\.dismiss) private var dismiss
        
        // Optional callback for additional actions after restore (used in Tutorial)
        var onRestore: (() -> Void)? = nil
        
        var body: some View {
            NavigationStack {
                VStack {
                    List {
                        if ck.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else if ck.error != nil {
                            UITemplates.iconButton(icon: "exclamationmark.icloud", text: String.LocalizationValue(ck.error!.localizedDescription))
                        } else if ck.allCSEs.isEmpty {
                            Text("No devices found.")
                        } else {
                            ForEach(ck.allCSEs) { ds in
                                Button {
                                    if selected == ds.id.recordName {
                                        selected = nil
                                    } else {
                                        selected = ds.id.recordName
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(ds.deviceName)
                                                .foregroundColor(.primary)
                                            // Modified Time
                                            if let modificationDate: Date = ds.modificationDate {
                                                Text("Last Updated: \(modificationDate.formatted(date: .abbreviated, time: .shortened))")
                                                    .foregroundColor(.secondary)
                                                    .font(.subheadline)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: selected == ds.id.recordName ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(.blue)
                                            .animation(.easeOut(duration: 0.15), value: selected)
                                    }
                                }
                                .contextMenu {
                                    Button(action: {
                                        ck.delete(recordID: ds.id)
                                        if selected == ds.id.recordName {
                                            selected = nil
                                        }
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            .onDelete(perform: { indexSet in
                                for index in indexSet {
                                    let ds = ck.allCSEs[index]
                                    ck.delete(recordID: ds.id)
                                    if selected == ds.id.recordName {
                                        selected = nil
                                    }
                                }
                            })
                        }
                    }
                    
                    Button(action: {
                        if let selected = selected,
                           let selectedDevice = ck.allCSEs.first(where: { $0.id.recordName == selected }) {
                            CSEDataManager.importDeviceCSEs(from: selectedDevice)
                            #if !os(visionOS)
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            #endif
                        }
                        dismiss()
                        onRestore?() // Call additional action if provided
                    }) {
                        UITemplates.tutorialButton(text: "Done")
                    }
                    .padding(EdgeInsets(top: 10, leading: 24, bottom: 24, trailing: 24))
                    .disabled(ck.isLocked || selected == nil)
                    .animation(.easeInOut(duration: 0.15), value: selected)
                }
                .navigationTitle("Choose Device")
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    ck.fetchAll()
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") {
                            dismiss()
                        }
                        .disabled(ck.isLocked)
                    }
                }
                #if !os(visionOS)
                .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
                #endif
            }
            .interactiveDismissDisabled(ck.isLocked)
        }
    }
    
    // Shared JSON import functionality for Tutorial and BackupView
    static func importJSONFile(from url: URL,
                               onSuccess: @escaping () -> Void = {},
                               onError: @escaping (String) -> Void = { _ in })
    {
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
