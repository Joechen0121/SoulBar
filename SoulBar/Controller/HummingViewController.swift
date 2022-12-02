//
//  HummingViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/12/1.
//

import UIKit
import Lottie

class HummingViewController: UIViewController {
    
    static let storyboardID = "HummingVC"
    
    @IBOutlet weak var startStopButton: UIButton!
    
    @IBOutlet weak var hummingTableView: UITableView!
    
    @IBOutlet weak var voiceView: UIView!
    
    private var voiceAnimation: AnimationView?
    
    private var musicAnimation: AnimationView?
    
    var hummingSongs = [Humming]()
    
    var isStart = false
    
    var client: ACRCloudRecognition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hummingTableView.dataSource = self
        
        self.title = "Recognize Humming"
        
        configureButton()
        
        configureAnimation()
        
        startMusicAnimation()
        
        configureACRCloud()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.client?.stopRecordRec()
    }
    
    func configureAnimation() {
        
        voiceAnimation = .init(name: "recording")
         
        voiceAnimation?.frame = voiceView.bounds
        
        voiceAnimation?.contentMode = .scaleAspectFit
        
        voiceAnimation?.loopMode = .loop
        
        voiceAnimation?.animationSpeed = 0.5
        
        voiceView.addSubview(voiceAnimation!)
        
        voiceAnimation!.play()
    }
    
    func startMusicAnimation() {
        
        musicAnimation = .init(name: "music")
        print("------", view.bounds)

        musicAnimation?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        //musicAnimation?.center = view.center
        
        musicAnimation?.contentMode = .scaleAspectFit
        
        musicAnimation?.loopMode = .loop
        
        musicAnimation?.animationSpeed = 0.5
        
        view.addSubview(musicAnimation!)
        
        musicAnimation!.play()
        
        musicAnimation?.isUserInteractionEnabled = false
        
        musicAnimation?.isHidden = true
    }
    
    func configureButton() {
        
        startStopButton.layer.borderColor = K.Colors.customRed.cgColor
        
        startStopButton.layer.borderWidth = 1.5
        
        startStopButton.layer.cornerRadius = startStopButton.bounds.height / 2
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
            
            self?.handleResult(result!, resType: resType)
        }
        
        self.client = ACRCloudRecognition(config: config)
        
    }
    
    @IBAction func startStopRecording(_ sender: UIButton) {

        // Prepare for stopping
        if isStart {
            
            musicAnimation?.isHidden = true

            self.client?.stopRecordRec()
            
            self.isStart = false
            
            DispatchQueue.main.async {
                
                self.startStopButton.setTitle("Start", for: .normal)
            }
        }
        
        // Prepare for starting
        else {
            print("Prepare for starting")
            if PlaySongManager.sharedInstance.player.timeControlStatus != .paused {
                
                PlaySongManager.sharedInstance.pauseMusic()
                
                NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerButton"), object: nil)
                
            }
            
            musicAnimation?.isHidden = false
            
            self.client?.startRecordRec()
            
            self.isStart = true
            
            DispatchQueue.main.async {
                
                self.startStopButton.setTitle("Stop", for: .normal)
            }
        }
        
    }
    
    func handleResult(_ result: String, resType: ACRCloudResultType) {
        
        do {
            
            guard let result = result.data(using: .utf8) else {
                
                musicAnimation?.isHidden = true
                
                self.client?.stopRecordRec()
                
                self.isStart = false
                
                DispatchQueue.main.async {
                    
                    self.startStopButton.setTitle("Start", for: .normal)
                }
                
                return
                
            }
            
            let data = try JSONDecoder().decode(HummingData.self, from: result)
            
            if let humming = data.metadata?.humming {
                
                self.hummingSongs = humming
            }
            
        } catch {
            
            print(error)
            
            musicAnimation?.isHidden = true
            
            self.client?.stopRecordRec()
            
            self.isStart = false
            
            DispatchQueue.main.async {
                
                self.startStopButton.setTitle("Start", for: .normal)
            }
            
            return
        }
        
        DispatchQueue.main.async {
            
            self.startStopButton.setTitle("Start", for: .normal)
    
            self.hummingTableView.reloadData()
            
            self.musicAnimation?.isHidden = true
            
            self.client?.stopRecordRec()
            
            self.isStart = false
        }
    }
}

extension HummingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return hummingSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HummingTableViewCell.identifier, for: indexPath) as? HummingTableViewCell else {
            
            fatalError("Cannot create humming cells")
        }
        
        cell.songName.text = hummingSongs[indexPath.row].title
        
        var artists: String = ""
        
        hummingSongs[indexPath.row].artists?.forEach { artist in
            
            if let name = artist.name {
                
                artists += name
                
                artists += " "
            }
        }
        
        cell.artists.text = artists
        
        return cell
    }
}
