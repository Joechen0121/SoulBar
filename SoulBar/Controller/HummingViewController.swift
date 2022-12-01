//
//  HummingViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/12/1.
//

import UIKit

class HummingViewController: UIViewController {
    
    static let storyboardID = "HummingVC"
    
    @IBOutlet weak var startStopButton: UIButton!
    
    @IBOutlet weak var hummingTableView: UITableView!
    
    var hummingSongs = [Humming]()
    
    var isStart = false
    
    var client: ACRCloudRecognition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hummingTableView.dataSource = self
        
        self.title = "Recognize Humming"
        
        // configureButton()
        
        configureACRCloud()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func configureButton() {
        
        startStopButton.layer.borderColor = UIColor.black.cgColor
        
        startStopButton.layer.borderWidth = 2
        
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

            self.client?.stopRecordRec()
            
            self.isStart = false
            
            DispatchQueue.main.async {
                
                self.startStopButton.setTitle("Start Humming", for: .normal)
            }
        }
        
        // Prepare for starting
        else {

            if PlaySongManager.sharedInstance.player.timeControlStatus != .paused {
                
                PlaySongManager.sharedInstance.pauseMusic()
                
                NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerButton"), object: nil)
                
            }
            
            self.client?.startRecordRec()
            
            self.isStart = true
            
            DispatchQueue.main.async {
                
                self.startStopButton.setTitle("Stop Humming", for: .normal)
            }
        }
        
    }
    
    func handleResult(_ result: String, resType: ACRCloudResultType) {
        
        do {
            
            guard let result = result.data(using: .utf8) else {
                
                self.client?.stopRecordRec()
                
                self.isStart = false
                
                return
                
            }
            
            let data = try JSONDecoder().decode(HummingData.self, from: result)
            
            if let humming = data.metadata?.humming {
                
                self.hummingSongs = humming
            }
            
        } catch {
            
            print(error)
            
            self.client?.stopRecordRec()
            
            self.isStart = false
            
            return
        }
        
        DispatchQueue.main.async {
    
            self.hummingTableView.reloadData()
            
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
