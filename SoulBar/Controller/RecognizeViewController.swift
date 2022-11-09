//
//  SearchViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import UIKit
import ShazamKit
import Pulsator

class RecognizeViewController: UIViewController {
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var searchImage: UIImageView!
    
    @IBOutlet weak var searchStatusLabel: UILabel!
    
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
    
    var state = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopButton.isHidden = true
        
        session.delegate = self
        
        pulsator.numPulse = 5
        
        pulsator.radius = 360
        
        pulsator.backgroundColor = UIColor.lightGray.cgColor

        pulsator.animationDuration = 5

        view.layer.insertSublayer(pulsator, below: searchImage.layer)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUpdate)))
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        state = 1
        
        pulsator.stop()
        
        stopListening()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pulsator.position = searchImage.layer.position
    }
    
    func requestMicrophone() -> Bool {
        
        var isPermissionDone = false
        
        AVAudioSession.sharedInstance().requestRecordPermission { isGranted in
            
            print("Microphone permissions \(isGranted)")
            isPermissionDone = isGranted

        }
        
        if isPermissionDone {
            
            return true
            
        }
        else {
            
            let alert = UIAlertController(title: "Error", message: "Please allow microphone usage from settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Open settings", style: .default) { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
            return false
        }
        
    }
    
    func stopListening() {
        
        audioEngine.stop()
        
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    private func startListening() {
        
        guard requestMicrophone() == true else { return }

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
            
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
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

            let recordingFormat = inputNode.outputFormat(forBus: 0)

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
        
        stopListening()
        
        pulsator.stop()
        
        stopButton.isHidden = true
        
        self.searchStatusLabel.text = "Tap to Start..."
        
        state = 1
        
    }
    
    func setupPulsatingLayer() {
        
        pulsatingLayer = CAShapeLayer()
        
        pulsatingLayer.path = circularPath.cgPath
        
        pulsatingLayer.strokeColor = UIColor.lightGray.cgColor
        
        pulsatingLayer.lineWidth = 10
        
        pulsatingLayer.fillColor = UIColor.clear.cgColor
        
        pulsatingLayer.lineCap = CAShapeLayerLineCap.round
        
        pulsatingLayer.position = view.center
        
        view.layer.addSublayer(pulsatingLayer)
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
        
        shapeLayer.strokeColor = UIColor.red.cgColor
        
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
        
        animation.toValue = 1.7
        
        animation.duration = 0.8
        
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
            stopButton.isHidden = true
            
            stopListening()
            
            pulsator.stop()
            
            self.searchStatusLabel.text = "Tap to Search..."
            
            state = 1
            
        case 1:
            print("processing")
            stopButton.isHidden = false
            
            pulsator.start()
            
            self.searchStatusLabel.text = "Processing..."
            
            startListening()
            
            searchImage.isUserInteractionEnabled = false
            
            state = 2
            
        case 2:
            print("end searching")
            stopButton.isHidden = true
            
            stopListening()
            
            pulsator.stop()
            
            self.searchStatusLabel.text = "End searching"
            
            state = 0
            
        default:
            
            print("Unknown state")
        }
    }
    
    @objc func handleStart() {

        self.searchStatusLabel.text = "Start"

    }
    
    @objc func handleSearch() {
        
        self.searchStatusLabel.text = "Searching"

    }
    
    
    @objc func handleEnd() {
        
        shapeLayer.removeFromSuperlayer()
        
        self.searchStatusLabel.text = "The End"
        
        setupShapeLayer()
        
    }
    
    @objc func handleProcessing() {
     
        self.searchStatusLabel.text = "Processing"
        
    }
}

extension RecognizeViewController: SHSessionDelegate {
    
    func session(_ session: SHSession, didFind match: SHMatch) {
        
        var songs = [SongsSearchInfo]()
        
        let items = match.mediaItems
        
        items.forEach { item in
            print(item.title ?? "title")
            print(item.artist ?? "artist")
            print(item.artworkURL?.absoluteURL ?? "Artwork url")
            
            if let title = item.title {
                
                MusicManager.sharedInstance.searchSongs(term: title, limit: 25) { result in
                    
                    
                    result.forEach { song in
                        
                        print(song.attributes?.artistName == item.artist)
                        
                        if song.attributes?.artistName == item.artist {

                            songs.append(song)
                            
                            DispatchQueue.main.async {
                                print("Stop listening")

                                self.pulsator.stop()

                                self.state = 0

                                self.stopListening()

                            }
                            
                            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {

                                playSongVC.songs = songs
                                
                                self.present(playSongVC, animated: true)
                            }
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
