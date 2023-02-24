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
    
    @IBAction func DoneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")
    override func viewDidLoad() {
        super.viewDidLoad()
        topText.text! = userDefaults!.string(forKey: "urltop") ?? "twitter.com/search?q="
        suffixText.text! = userDefaults!.string(forKey: "urlsuffix") ?? "&f=live"
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
    
    @IBAction func endInputtop(_ sender: Any) {
    }
    @IBAction func endInputsuffix(_ sender: Any) {
    }
}
