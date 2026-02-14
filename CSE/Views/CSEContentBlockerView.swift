//
//  CSEContentBlockerView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2026/02/14.
//

import SwiftUI

struct CSEContentBlockerView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 5) {
                    Image("cse-content-blocker")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .accessibilityHidden(true)
                        .padding(.bottom, 10)
                    Text("CSE Content Blocker")
                        .font(.title2)
                        .bold()
                    Text("This is an additional extension that blocks Safari's search engine to prevent leaks of your search queries.")
                        .foregroundColor(.secondary)
                }
                
                // Open Settings Button
                UITemplates.OpenSettingsButton()
            }
            
            Section {
                // Safariの制約のため、あなたがSafariの設定で選択した検索エンジンは、CSEの使用中であってもあなたの検索内容を知ることができる可能性があります。
                // このコンテンツブロッカーは、Safariの検索エンジンを事前にブロックすることで、検索クエリの漏洩を防止します。
                // ただし、いくつかの不具合を引き起こすことがわかっているため、デフォルトではオフになっています。Safariの拡張機能の設定から任意で有効にすることができます。
                Text("Due to Safari's limitations, the search engine you select in Safari settings may be able to know your search queries even when using CSE.")
                Text("This content blocker prevents leakage of search queries by blocking Safari's search engine in advance.")
                Text("However, it is known to cause some issues, so it is turned off by default. You can enable it from the Safari Extensions settings if you wish.")
            } header: {
                Text("What is CSE Content Blocker?")
                    .textCase(nil)
            } footer: {
                Link("More About CSE & Privacy...", destination: URL(string: "https://cizz.uk/cse/privacy-report")!)
                    .font(.caption)
                    .padding(.bottom, 20)
            }
            
            Section {
                // 古いバージョンのSafariでは全く検索ができなくなる。
                // CSEの設定で「デフォルトの検索エンジン」をオフにすると、検索ができなくなる。
                // POSTデータを用いた検索ができなくなる。
                // 検索をしたときに、不要なメッセージが一時的に表示される。
                // 不要な検索履歴が残ってしまう。
                // ブロックされたページに戻ると、意図しない動作をする。
                Text("Search becomes completely impossible on older versions of Safari.")
                Text("If Default Search Engine is turned off in the CSE settings, searching becomes impossible.")
                Text("Searching using POST Data becomes impossible.")
                Text("Unnecessary messages are temporarily displayed when a search is performed.")
                Text("Unnecessary search history may remain.")
                Text("Unexpected behavior occurs when going back to a blocked page.")
                Text("And more...")
            } header: {
                Text("Known Issues")
                    .textCase(nil)
            }
        }
        .navigationTitle("CSE Content Blocker")
        .navigationBarTitleDisplayMode(.inline)
    }
}
