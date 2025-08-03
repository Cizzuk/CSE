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
                Section {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
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
                        exportToShareSheet()
                    }) {
                        UITemplates.iconButton(icon: "arrow.up.document", text: "Export as JSON")
                    }
                    Button(action: {
                        showingFileImport = true
                    }) {
                        UITemplates.iconButton(icon: "square.and.arrow.down", text: "Import from JSON")
                    }
                }
            }
            .navigationTitle("Backup & Restore")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingRestoreSheet) {
                CloudRestoreView()
            }
            .alert(isPresented: $showingErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage)
                )
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
        
        // Export JSON and show share sheet
        private func exportToShareSheet() {
            guard let jsonString = CSEDataManager.exportDeviceCSEsAsJSON() else { return }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
            let fileName = "CSE-\(formatter.string(from: Date())).json"
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            do {
                try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
                let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let rootViewController = windowScene?.windows.first?.rootViewController
                rootViewController?.present(activityViewController, animated: true,completion: {})
            } catch {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
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
                            Text(ck.error!.localizedDescription)
                                .foregroundColor(.red)
                        } else if ck.allCSEs.isEmpty {
                            Text("No devices found.")
                                .foregroundColor(.secondary)
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
                            }
                        }
                    }
                    
                    Button(action: {
                        if let selected = selected,
                           let selectedDevice = ck.allCSEs.first(where: { $0.id.recordName == selected }) {
                            CSEDataManager.importDeviceCSEs(from: selectedDevice)
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
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
                    }
                }
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
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            onError(error.localizedDescription)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}
