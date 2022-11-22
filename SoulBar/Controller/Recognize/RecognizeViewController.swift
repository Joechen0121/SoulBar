//
//  SearchViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import UIKit
import ShazamKit
import Pulsator
import Lottie
import SwiftUI
import Intents
import OSLog
import IntentsUI

class RecognizeViewController: UIViewController {
    
    static let storyboardID = "RecognizeVC"
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var searchImage: UIImageView!
    
    @IBOutlet weak var searchStatusLabel: UILabel!
    
    @IBOutlet weak var micImage: UIImageView!
    
    @IBOutlet weak var noticeLabel: UILabel!
    
    @IBOutlet weak var processingView: AnimationView!
    
    var displayLink: CADisplayLink?
    
    var pulseLayers = [CAShapeLayer]()
    
    var pulsatingLayer: CAShapeLayer!
    
    let shapeLayer = CAShapeLayer()
    
    let pulsator = Pulsator()
    
    let circularPath = UIBezierPath(arcCenter: .zero, radius: 70, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
    
    let session = SHSession()
    
    let audioEngine = AVAudioEngine()
    
    let signatureGenerator = SHSignatureGenerator()
    
    var isRecording = false
    
    var isFound = false
    
    var state = 1
    
    static let recognizeActivityType = "com.SoulBar.recognize"
    
    let recognizePageActivity: NSUserActivity = {
        
        let userActivity = NSUserActivity(activityType: recognizeActivityType)
        
        userActivity.title = "SoulBar Recognize"
        
        userActivity.suggestedInvocationPhrase = "SoulBar 辨識"
        
        userActivity.isEligibleForSearch = true
        
        userActivity.isEligibleForPrediction = true
        
        return userActivity
    }()
    
    let gradientLayer = CAGradientLayer()
    
    var timer: Timer? {
        
        didSet {
            
            oldValue?.invalidate()
        }
    }
    
    @IBOutlet weak var siriButton: UIButton!
    
    @IBAction func addToSiri(_ sender: UIButton) {
        
        guard let userActivity = self.userActivity else { return }
        let shortcut = INShortcut(userActivity: userActivity)
        let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
        viewController.modalPresentationStyle = .formSheet
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopButton.isHidden = true
        
        session.delegate = self
        
        configurePulse()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUpdate)))
        
        userActivity = recognizePageActivity
        
        userActivity?.becomeCurrent()
        
        siriButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupPulsatingLayer()
        
        animatePulsatingLayer()
        
        noticeLabel.isHidden = true
        
        isFound = false
        
        animateProcessingViewStop()
        
        initViewStatus()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        initViewStatus()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pulsator.position = searchImage.layer.position
    }
    
    func configurePulse() {
        
        pulsator.numPulse = 5
        
        pulsator.radius = 360
        
        pulsator.backgroundColor = K.Colors.customRed.cgColor

        pulsator.animationDuration = 5

        view.layer.insertSublayer(pulsator, below: searchImage.layer)
    }
    
    func initViewStatus() {
        
        self.pulsator.stop()
        
        self.siriButton.isHidden = false

        self.state = 1

        self.stopListening()
        
        self.noticeLabel.isHidden = true
        
        self.stopButton.isHidden = true
        
        self.micImage.isHidden = false
        
        self.searchStatusLabel.text = "Tap to Search"
    }
    
    func requestMicrophone() -> Bool {
        
        var isPermissionDone = false
        
        AVAudioSession.sharedInstance().requestRecordPermission { isGranted in
            
            print("Microphone permissions \(isGranted)")
            isPermissionDone = isGranted
            
            if !isPermissionDone {
                
                let alert = UIAlertController(title: "Error", message: "Please allow microphone usage from settings", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Open settings", style: .default) { _ in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                })
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)

            }

        }
        
        return isPermissionDone
    }
    
    func stopListening() {
        
        audioEngine.stop()
        
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    private func startListening() {
        
        //guard requestMicrophone() == true else { return }

        guard !audioEngine.isRunning else {
            
            audioEngine.stop()
            
            DispatchQueue.main.async {
                
                self.isRecording = false
                
            }
            
            return
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            
            try audioSession.setCategory(.playAndRecord)
            
            // try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            try audioSession.setActive(true)
            
        } catch {
            print("setting category or active state failed")
            
        }
        
        PlaySongManager.sharedInstance.pauseMusic()
        
        NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerButton"), object: nil)
        
        audioSession.requestRecordPermission { granted in

            guard granted else { return }

            try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            let inputNode = self.audioEngine.inputNode

            inputNode.removeTap(onBus: 0)

            let recordingFormat = inputNode.inputFormat(forBus: 0)

            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
    
                self.session.matchStreamingBuffer(buffer, at: nil)
            }
        }
        
        self.audioEngine.prepare()
        
        do {
            
            try self.audioEngine.start()
            
        } catch {
            
            assertionFailure(error.localizedDescription)
            
        }
        
        DispatchQueue.main.async {
            
            self.isRecording = false
            
        }
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        
        initViewStatus()
        
        animateProcessingViewStop()
        
    }
    
    func setupPulsatingLayer() {
        
        pulsatingLayer = CAShapeLayer()
        
        pulsatingLayer.path = circularPath.cgPath
        
        pulsatingLayer.strokeColor = UIColor.lightGray.cgColor
        
        pulsatingLayer.lineWidth = 1
        
        pulsatingLayer.fillColor = UIColor.lightGray.cgColor
        
        pulsatingLayer.lineCap = CAShapeLayerLineCap.round
        
        pulsatingLayer.position = view.center
        
        searchImage.layer.addSublayer(pulsatingLayer)
    }
    
    func animateProcessingViewStart() {
        
        processingView.isHidden = false
        
        processingView.loopMode = .loop
        
        view.addSubview(processingView)
        
        processingView.play()
        
    }
    
    func animateProcessingViewStop() {
        
        processingView.stop()
        
        processingView.isHidden = true
        
    }
    
    func setupTrackLayer() {
        
        let trackLayer = CAShapeLayer()
        
        trackLayer.path = circularPath.cgPath
        
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        
        trackLayer.lineWidth = 15
        
        trackLayer.fillColor = UIColor.clear.cgColor
        
        trackLayer.lineCap = CAShapeLayerLineCap.round
        
        trackLayer.position = view.center
        
        view.layer.addSublayer(trackLayer)
    }
    
    func setupShapeLayer() {
        
        shapeLayer.path = circularPath.cgPath
        
        shapeLayer.strokeColor = K.Colors.customRed.cgColor
        
        shapeLayer.lineWidth = 15
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        
        shapeLayer.position = view.center
        
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(shapeLayer)
    }
    
    func animatePulsatingLayer() {
        
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.toValue = 1.2
        
        animation.duration = 1.5
        
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        animation.autoreverses = true
        
        animation.repeatCount = .infinity
        
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    @objc func handleUpdate() {

        guard requestMicrophone() == true else { return }
        
        switch self.state {
        
        case 0:
            print("tap to start")
            
            animateProcessingViewStop()
            
            siriButton.isHidden = false
            
            noticeLabel.isHidden = true
            
            micImage.isHidden = false
            
            searchStatusLabel.fadeTransition(0.4)
            
            stopButton.isHidden = true
            
            stopListening()
            
            pulsator.stop()
            
            self.searchStatusLabel.text = "Tap to Search"
            
            state = 1
            
        case 1:
            print("processing")

            animateProcessingViewStart()
            
            siriButton.isHidden = true
            
            noticeLabel.isHidden = false
            
            micImage.isHidden = true
            
            stopButton.isHidden = false
            
            searchImage.stopAnimating()
            
            pulsator.start()
            
            searchStatusLabel.fadeTransition(0.4)
            
            self.searchStatusLabel.text = "Processing"
            
            startListening()
            
            searchImage.isUserInteractionEnabled = false
            
            state = 2
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 12.0, repeats: false) { timer in

                guard self.state == 2 else {
                    
                    return
                }
                
                if self.isFound == false {
                    
                    DispatchQueue.main.async {
                        
                        self.initViewStatus()
                        
                    }
                    
                    if let recErrVC = self.storyboard?.instantiateViewController(withIdentifier: RecognizeErrorViewController.storyboardID) as? RecognizeErrorViewController {
                    
                        recErrVC.modalPresentationStyle = .currentContext
                        
                        recErrVC.modalTransitionStyle = .crossDissolve
                        
                        self.present(recErrVC, animated: true)
                    }
                }
                else { }
            }
            
        case 2:
            print("end searching")
            
            animateProcessingViewStop()
            
            siriButton.isHidden = true
            
            stopButton.isHidden = true
            
            processingView.isHidden = true
            
            noticeLabel.isHidden = true
            
            stopListening()
            
            pulsator.stop()
            
            searchStatusLabel.fadeTransition(0.4)
            
            self.searchStatusLabel.text = "End searching"
            
            state = 0
            
        default:
            
            print("Unknown state")
        }
    }
}

extension RecognizeViewController: SHSessionDelegate {
    
    func session(_ session: SHSession, didFind match: SHMatch) {
        
        var songs = [SongsSearchInfo]()
        
        let items = match.mediaItems
        
        items.forEach { item in

            if let musicID = item.appleMusicID {
                
                MusicManager.sharedInstance.fetchSong(with: musicID) { result in
                    
                    songs = result
                    
                    DispatchQueue.main.async {
                        print("Stop listening")
                        
                        self.isFound = true
                        
                        self.initViewStatus()
                        
                    }
                    
                    if let id = KeychainManager.sharedInstance.id {
                        
                        FirebaseHistoryManager.sharedInstance.addHistoryPlayData(with: musicID) {
                            
                            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                                
                                playSongVC.songs = songs
                                
                                playSongVC.modalPresentationStyle = .fullScreen
                                
                                self.present(playSongVC, animated: true)
                            }
                        }
                        
                    }
                    else {
                        
                        if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                            
                            playSongVC.songs = songs
                            
                            playSongVC.modalPresentationStyle = .fullScreen
                            
                            self.present(playSongVC, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        
        if let error = error {
            
            print(error)
        }
    }
}

extension RecognizeViewController: INUIAddVoiceShortcutViewControllerDelegate {
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true)
    }

    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true)
    }
}
