//
//  OpenAIConsoleViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/12/11.
//

import UIKit

class OpenAIConsoleViewController: UIViewController {
    
    static let storyboardID = "openAIConsoleVC"

    @IBOutlet weak var receiveTextView: UITextView!
    
    @IBOutlet weak var sendTextView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    var activityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sendTextView.delegate = self
    }
    
    @IBAction func dismissButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
        guard let text = sendTextView.text else { return }
        
        activeActivityView()
        
        sendButton.isUserInteractionEnabled = false
        
        OpenAIManager.sharedInstance.fetchResponses(text: text) { result in
            
            DispatchQueue.main.async {
                
                self.receiveTextView.text = result
                
                self.activityIndicatorView.stopAnimating()
                
                self.activityIndicatorView.removeFromSuperview()
                
                self.sendButton.isUserInteractionEnabled = true
            }
        }
    }
    
    func activeActivityView() {
        
        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        
        activityIndicatorView.tintColor = .black
        
        activityIndicatorView.center = self.view.center
        
        self.view.addSubview(activityIndicatorView)
        
        activityIndicatorView.startAnimating()
    }

}

extension OpenAIConsoleViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        textView.text = ""
    }
}

