//
//  EditSEView+AdvSettings.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/12/10.
//

import SwiftUI

extension EditSEView {
    struct AdvSettingsView: View {
        @Binding var cseData: CSEDataManager.CSEData
        @Binding var isShowingPostData: Bool
        @Binding var isOpenSheet: Bool
        
        var body: some View {
            NavigationStack {
                List {
                    Section {
                        HStack {
                            Text("Space Character")
                            Spacer()
                            TextField("Space Character", text: $cseData.spaceCharacter, prompt: Text("+"))
                                .disableAutocorrection(true)
                                .textInputAutocapitalization(.never)
                                .environment(\.layoutDirection, .leftToRight)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .multilineTextAlignment(.trailing)
                                .submitLabel(.done)
                        }
                    } footer: {
                        Text("Use a specific character as the query separator. Default is +.")
                    }
                    
                    Section {
                        Toggle("Disable Percent-encoding", isOn: $cseData.disablePercentEncoding)
                    } footer: {
                        Text("Disable percent-encoding of queries. When enabled, some symbols and non-ASCII characters may become unavailable.")
                    }
                    
                    Section {
                        HStack {
                            Text("Max Query Length")
                            Spacer()
                            TextField("Max Query Length", value: $cseData.maxQueryLength, format: .number, prompt: Text("32"))
                                .keyboardType(.numberPad)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .multilineTextAlignment(.trailing)
                                .submitLabel(.done)
                        }
                    } footer: {
                        Text("Truncate the query to the specified character count. Blank to disable.")
                    }
                    
                    Section {
                        Button(action: { isShowingPostData = true }) {
                            HStack {
                                Text("POST Data")
                                Spacer()
                                Text("\(cseData.post.count)")
                                    .foregroundStyle(.secondary)
                                Image(systemName: "chevron.forward")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .foregroundStyle(.primary)
                        .contextMenu {
                            Button(role: .destructive) {
                                cseData.post = []
                            } label: {
                                Label("Delete All POST Data", systemImage: "trash")
                            }
                        }
                    } footer: {
                        Text("Not Recommended. Search using POST request. Blank to disable.")
                    }
                }
                .scrollToDismissesKeyboard()
                .navigationTitle("Advanced Settings")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $isShowingPostData) {
                    PostDataView(post: $cseData.post, isOpenSheet: $isShowingPostData)
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", systemImage: "checkmark") {
                            isOpenSheet = false
                        }
                    }
                    #if !os(visionOS)
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        } label: {
                            Label("Done", systemImage: "checkmark")
                        }
                    }
                    #endif
                }
            }
        }
    }
}
