//
//  PrivacyViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/24.
//

import UIKit
import WebKit

class PrivacyViewController: UIViewController {

    static let storyboardID = "PrivacyVC"
    
    @IBOutlet weak var privacyWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setWebView()
    }
    
    private func setWebView() {
    
        guard let url = URL(string: "https://www.privacypolicies.com/live/d07ffa6f-447d-4341-bb7b-df67d2c8f462") else { return }

        self.privacyWebView.load(NSURLRequest(url: url) as URLRequest)
    }
}
