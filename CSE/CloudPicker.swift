//
//  CloudPickerView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/09/14.
//

import SwiftUI

//  1. restoreAll: Tapping a device immediately imports all CSE data from that device and dismisses.
//  2. pickSingleCSE: Tapping a device navigates to a per-device picker allowing user to select one CSE (default/private/quick) to import into current edit binding.
class CloudPicker {
    struct CloudPickerView: View {
        private enum Mode {
            case restoreAll(onRestore: (() -> Void)?)
            case pickSingleCSE(cseData: Binding<CSEDataManager.CSEData>, isOpenSheet: Binding<Bool>)
        }
        
        private let mode: Mode
        @Environment(\.dismiss) private var dismiss
        @StateObject private var ck = CloudKitManager()
        @State private var isFirstLoad: Bool = true
        
        // Restore All initializer
        init(onRestore: (() -> Void)? = nil) {
            self.mode = .restoreAll(onRestore: onRestore)
        }
        
        // Pick Single CSE initializer
        init(cseData: Binding<CSEDataManager.CSEData>, isOpenSheet: Binding<Bool>) {
            self.mode = .pickSingleCSE(cseData: cseData, isOpenSheet: isOpenSheet)
        }
        
        var body: some View {
            NavigationStack {
                listContent
                    .navigationTitle("Choose Device")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        toolbarItems
                    }
                // Attach destination at stack level (value-based navigation)
                    .navigationDestination(for: CSEDataManager.DeviceCSEs.self) { ds in
                        if case let .pickSingleCSE(cseData, isOpenSheet) = mode {
                            let parsed = CSEDataManager.parseDeviceCSEs(ds)
                            DeviceCSESelectionView(
                                deviceName: ds.deviceName,
                                cseData: cseData,
                                isOpenSheet: isOpenSheet,
                                defaultCSE: parsed.defaultCSE,
                                privateCSE: parsed.privateCSE,
                                quickCSE: parsed.quickCSE
                            )
                        }
                    }
            }
            .interactiveDismissDisabled(ck.isLocked)
            .task {
                if isFirstLoad {
                    ck.fetchAll()
                    isFirstLoad = false
                }
            }
        }
        
        @ViewBuilder
        private var listContent: some View {
            List {
                if ck.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if let error = ck.error {
                    UITemplates.iconButton(icon: "exclamationmark.icloud", text: String.LocalizationValue(error.localizedDescription))
                } else if ck.allCSEs.isEmpty {
                    Text("No devices found.")
                } else {
                    switch mode {
                    case .restoreAll:
                        restoreAllList
                    case .pickSingleCSE:
                        pickSingleCSEList
                    }
                }
            }
        }
        
        // List when restoring all immediately
        private var restoreAllList: some View {
            ForEach(ck.allCSEs) { ds in
                Button {
                    CSEDataManager.importDeviceCSEs(from: ds)
                    #if !os(visionOS)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    #endif
                    if case let .restoreAll(onRestore) = mode {
                        onRestore?()
                    }
                    dismiss()
                } label: {
                    deviceRow(ds)
                }
                .contextMenu {
                    Button(role: .destructive) {
                        ck.delete(recordID: ds.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .disabled(ck.isLocked)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) { ck.delete(recordID: ds.id) } label: { Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        
        // List when picking single CSE -> navigate to detail picker
        private var pickSingleCSEList: some View {
            ForEach(ck.allCSEs) { ds in
                NavigationLink(value: ds) { deviceRow(ds) }
                    .contextMenu {
                        Button(role: .destructive) {
                            ck.delete(recordID: ds.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .disabled(ck.isLocked)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            ck.delete(recordID: ds.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        
        @ToolbarContentBuilder
        private var toolbarItems: some ToolbarContent {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                    if case let .pickSingleCSE(_, isOpenSheet) = mode {
                        isOpenSheet.wrappedValue = false
                    }
                }
                .disabled(ck.isLocked)
            }
        }
        
        private func deviceRow(_ ds: CSEDataManager.DeviceCSEs) -> some View {
            VStack(alignment: .leading) {
                Text(ds.deviceName)
                    .foregroundColor(.primary)
                if let modificationDate: Date = ds.modificationDate {
                    Text("Last Updated: \(modificationDate.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
        }
    }
    
    // Detail picker for selecting a single CSE from a device (used in pickSingleCSE mode)
    private struct DeviceCSESelectionView: View {
        @Environment(\.dismiss) private var dismiss
        let deviceName: String
        @Binding var cseData: CSEDataManager.CSEData
        @Binding var isOpenSheet: Bool
        let defaultCSE: CSEDataManager.CSEData
        let privateCSE: CSEDataManager.CSEData
        let quickCSE: [String: CSEDataManager.CSEData]
        @State private var originalID: String? = nil
        
        var body: some View {
            List {
                if defaultCSE.url != "" {
                    Section {
                        Button {
                            select(defaultCSE, keepKeyword: true)
                        } label: {
                            cseSummary(title: "Default Search Engine", cse: defaultCSE)
                        }
                    }
                }
                if privateCSE.url != "" {
                    Section {
                        Button {
                            select(privateCSE, keepKeyword: true)
                        } label: {
                            cseSummary(title: "Private Search Engine", cse: privateCSE)
                        }
                    }
                }
                if quickCSE.count > 0 {
                    Section {
                        ForEach(quickCSE.keys.sorted(), id: \.self) { key in
                            if let se = quickCSE[key] {
                                let displayName = se.name != "" ? se.name : key
                                Button {
                                    select(se, keepKeyword: false)
                                } label: {
                                    cseSummary(title: displayName, cse: se)
                                }
                            }
                        }
                    } header: {
                        Text("Quick Search Engines")
                    }
                }
            }
            .navigationTitle(deviceName)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                originalID = cseData.keyword
            }
        }
        
        private func select(_ selected: CSEDataManager.CSEData, keepKeyword: Bool) {
            var newData = selected
            if keepKeyword {
                newData.keyword = originalID ?? selected.keyword
            }
            cseData = newData
            isOpenSheet = false
            dismiss()
        }
        
        private func cseSummary(title: String, cse: CSEDataManager.CSEData) -> some View {
            VStack(alignment: .leading) {
                Text(title)
                    .bold()
                    .foregroundColor(.primary)
                Text(cse.url)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
        }
    }
}
