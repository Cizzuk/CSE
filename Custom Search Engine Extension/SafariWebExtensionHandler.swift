//
//  SafariWebExtensionHandler.swift
//  Customize Search Engine Extension
//
//  Created by Cizzuk on 2022/07/23.
//

import SafariServices
import os.log

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {

    let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")
    
    func beginRequest(with context: NSExtensionContext) {
        
        struct Settings: Encodable {
            let type: String
            let urltop: String
            let urlsuffix: String
            let searchengine: String
            let adv_disablechecker: Bool
            let adv_redirectat: String
        }
        
        let settings = Settings(
            type: "native",
            urltop: userDefaults!.string(forKey: "urltop") ?? "https://archive.org/search?query=",
            urlsuffix: userDefaults!.string(forKey: "urlsuffix") ?? "",
            searchengine: userDefaults!.string(forKey: "searchengine") ?? "google",
            adv_disablechecker: userDefaults!.bool(forKey: "adv_disablechecker"),
            adv_redirectat: userDefaults!.string(forKey: "adv_redirectat") ?? "loading"
        )
        
        do {
            let data = try JSONEncoder().encode(settings)
            let json = String(data: data, encoding: .utf8)!
            let extensionItem = NSExtensionItem()
            extensionItem.userInfo = [ SFExtensionMessageKey: json ]
            context.completeRequest(returningItems: [extensionItem], completionHandler: nil)
        } catch {
            print("error")
        }
    }

}
