//
//  SettingsController.swift
//  Custom Search Engine
//
//  Created by tsg0o0 on 2022/07/24.
//

import UIKit

class SettingsController: UIViewController {
    
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var suffixText: UITextField!
    @IBOutlet weak var engineSelector: UISegmentedControl!
    
    @IBAction func DoneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")
    override func viewDidLoad() {
        super.viewDidLoad()
        topText.text! = userDefaults!.string(forKey: "urltop") ?? "https://twitter.com/search?q="
        suffixText.text! = userDefaults!.string(forKey: "urlsuffix") ?? "&f=live"
        
        let engineSet = userDefaults!.string(forKey: "searchengine") ?? "duckduckgo"
        if engineSet == "duckduckgo" {
            engineSelector.selectedSegmentIndex = 0
        }else if engineSet == "sogou" {
            engineSelector.selectedSegmentIndex = 1
        }else if engineSet == "yandex" {
            engineSelector.selectedSegmentIndex = 2
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func editInputTop(_ sender: Any) {
        userDefaults!.set(topText.text!, forKey: "urltop")
    }
    @IBAction func editInputSuffix(_ sender: Any) {
        userDefaults!.set(suffixText.text!, forKey: "urlsuffix")
    }
    
    @IBAction func editSegmentEngine(_ sender: Any) {
        print("aaaa")
        if engineSelector.selectedSegmentIndex == 0 {
            userDefaults!.set("duckduckgo", forKey: "searchengine")
        }else if engineSelector.selectedSegmentIndex == 1 {
            userDefaults!.set("sogou", forKey: "searchengine")
        }else if engineSelector.selectedSegmentIndex == 2 {
            userDefaults!.set("yandex", forKey: "searchengine")
        }
    }
    
    @IBAction func endInputtop(_ sender: Any) {
    }
    @IBAction func endInputsuffix(_ sender: Any) {
    }
}
