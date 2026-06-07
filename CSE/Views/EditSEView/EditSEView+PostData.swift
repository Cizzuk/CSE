//
//  EditSEView+PostData.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/12/10.
//

import SwiftUI

extension EditSEView {
    struct PostDataView: View {
        @Binding var post: [[String: String]]
        @Binding var isOpenSheet: Bool
        
        var body: some View {
            NavigationStack {
                List {
                    Section {}
                    header: {
                        Text("Not Recommended")
                            .textCase(.none)
                    }
                    footer: {
                        VStack(alignment: .leading) {
                            Text("This feature is not recommended unless the search engine you want to use absolutely requires POST data. It does not improve privacy and may cause unstable behavior.")
                            Spacer()
                            Text("May not work on some operating systems or versions of Safari.")
                        }
                    }
                    // POST Data
                    Section {
                        ForEach(post.indices, id: \.self) { index in
                            HStack {
                                TextField("Key", text: binding(for: index, key: "key"))
                                    .environment(\.layoutDirection, .leftToRight)
                                TextField("Value", text: binding(for: index, key: "value"))
                                    .environment(\.layoutDirection, .leftToRight)
                            }
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                            .submitLabel(.done)
                        }
                        .onDelete(perform: { index in
                            withAnimation() { post.remove(atOffsets: index) }
                        })
                        
                        Button(action: {
                            withAnimation { post.append(["key": "", "value": ""]) }
                        })  {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .accessibilityHidden(true)
                                Text("Add POST Data")
                            }
                        }
                    } footer: { Text("Replace query with %s") }
                }
                .scrollToDismissesKeyboard()
                .navigationTitle("POST Data")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", systemImage: "checkmark") {
                            isOpenSheet = false
                        }
                    }
                }
            }
        }
        
        private func binding(for index: Int, key: String) -> Binding<String> {
            Binding<String>(
                get: { return post[index][key] ?? "" },
                set: { newValue in post[index][key] = newValue }
            )
        }
    }
}
