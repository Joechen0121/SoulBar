//
//  HummingViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/12/1.
//

import UIKit
import Lottie
import Pulsator

class HummingViewController: UIViewController {
    
    static let storyboardID = "HummingVC"
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var hummingView: UIImageView!
    
    @IBOutlet weak var noticeLabel: UILabel!
    
    let pulsator = Pulsator()
    
    var hummingSongs = [Humming]()
    
    var pulsatingLayer: CAShapeLayer!
    
    var isStart = false
    
    var client: ACRCloudRecognition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Recognize Humming"
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(startStopRecording)))
        
        configurePulse()
        
        configureACRCloud()
        
        self.stopButton.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pulsator.position = hummingView.layer.position
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.client?.stopRecordRec()
    }
    
    func noResultAlert() {
        
        let alertController = UIAlertController(
            title: "",
            message: "Not Found. Please try again.",
            preferredStyle: .alert)

        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil)
        alertController.addAction(okAction)

        self.present(
          alertController,
          animated: true,
          completion: nil)
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        
        initHummingStatus()
    }
    
    func configurePulse() {
        
        pulsator.numPulse = 5
        
        pulsator.radius = 360
        
        pulsator.backgroundColor = K.Colors.customRed.cgColor

        pulsator.animationDuration = 5

        view.layer.insertSublayer(pulsator, below: hummingView.layer)
    }
    
    func configureACRCloud() {
        
        let config = ACRCloudConfig()
        
        config.accessKey = "eea6d2606317988c56e5d40d826b12a7"
        config.accessSecret = "axfGTwsOCUV2L15UxA78HKYSblmkqJ4O2xuYpjt3"
        config.host = "identify-eu-west-1.acrcloud.com"
        
        config.recMode = rec_mode_remote
        config.requestTimeout = 10
        config.protocol = "https"
        
        config.resultBlock = { [weak self] result, resType in
            
            guard let result = result else { return }
            
            self?.handleResult(result, resType: resType)
        }
        
        self.client = ACRCloudRecognition(config: config)
        
    }
    
    @objc func startStopRecording() {

        if isStart {
            
            initHummingStatus()
        }
        else {
            
            if PlaySongManager.sharedInstance.player.timeControlStatus != .paused {
                
                PlaySongManager.sharedInstance.pauseMusic()
                
                NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerButton"), object: nil)
                
            }
            
            self.stopButton.isHidden = false
            
            self.client?.startRecordRec()
            
            self.isStart = true
            
            pulsator.start()
            
            DispatchQueue.main.async {
                
                self.noticeLabel.text = "Recording your voice..."
            }
        }
    }
    
    func initHummingStatus() {
        
        self.stopButton.isHidden = true
        
        self.pulsator.stop()
        
        self.client?.stopRecordRec()
        
        self.isStart = false
        
        DispatchQueue.main.async {
            
            self.noticeLabel.text = "Tap to Start humming"
        }
        
    }
    
    func handleResult(_ result: String, resType: ACRCloudResultType) {
        
        do {
            
            guard let result = result.data(using: .utf8) else {
                
                self.initHummingStatus()
                
                self.noResultAlert()
                
                return
                
            }
            
            let data = try JSONDecoder().decode(HummingData.self, from: result)
            
            if let humming = data.metadata?.humming {
                
                self.hummingSongs = humming
            }
            
        } catch {
            
            print(error)
            
            initHummingStatus()
            
            self.noResultAlert()
            
            return
        }
        
        initHummingStatus()
        
        DispatchQueue.main.async {
            
            if let hummingDetailVC = self.storyboard?.instantiateViewController(withIdentifier: HummingDetailViewController.storyboardID) as? HummingDetailViewController {

                hummingDetailVC.hummingSongs = self.hummingSongs
                
                self.present(hummingDetailVC, animated: true)
            }
        }
    }
}
