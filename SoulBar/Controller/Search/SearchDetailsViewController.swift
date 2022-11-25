//
//  SearchDetailsViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/28.
//

import UIKit
import TransitionButton
import Speech
import AWSRekognition

class SearchDetailsViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    enum SearchType: Int {
        
        case all = 0
        
        case artist
        
        case song
        
        case album
    }
    
    let allType = SearchType.all.rawValue
    
    let artistType = SearchType.artist.rawValue
    
    let songType = SearchType.song.rawValue
    
    let albumType = SearchType.album.rawValue
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchDetailsTableView: UITableView!
    
    @IBOutlet weak var allButton: TransitionButton!
    
    @IBOutlet weak var artistButton: TransitionButton!
    
    @IBOutlet weak var songButton: TransitionButton!
    
    @IBOutlet weak var albumButton: TransitionButton!
    
    @IBOutlet weak var voiceRecogniztion: UIButton!
    
    @IBOutlet weak var buttonStackView: UIStackView!
    
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    static let storyboardID = "SearchDetailsVC"
    
    var activityIndicatorView = UIActivityIndicatorView()
    
    var songs = [SongsSearchInfo]()
    
    var albums = [AlbumsSearchInfo]()
    
    var artists = [ArtistsSearchInfo]()
    
    var isRecognizing = false
    
    var buttonTag = 0
    
    var rekognitionObject: AWSRekognition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchDetailsTableView.dataSource = self
        
        searchDetailsTableView.delegate = self
        
        searchDetailsTableView.showsVerticalScrollIndicator = false
        
        searchDetailsTableView.showsHorizontalScrollIndicator = false
        
        searchTextField.delegate = self
        
        speechRecognizer.delegate = self
        
        searchDetailsTableView.register(UINib.init(nibName: SearchAllResultTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SearchAllResultTableViewCell.identifier)
        
        searchDetailsTableView.register(UINib.init(nibName: SearchArtistsResultTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SearchArtistsResultTableViewCell.identifier)
        
        searchDetailsTableView.register(UINib.init(nibName: SearchSongsResultTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SearchSongsResultTableViewCell.identifier)
        
        searchDetailsTableView.register(UINib.init(nibName: SearchAlbumsResultTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SearchAlbumsResultTableViewCell.identifier)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        
        longGesture.minimumPressDuration = 0.5
        
        voiceRecogniztion.addTarget(self, action: #selector(shortPressed), for: .touchUpInside)
        
        voiceRecogniztion.addGestureRecognizer(longGesture)
        
        voiceRecogniztion.isUserInteractionEnabled = true
        
        configureButton()
        
        configureTextField()
        
        self.navigationItem.title = "Search"
        
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    }
    
    @IBAction func celebrityRecognize(_ sender: UIButton) {
     
        print("celebrity button")
        
        let pickerController = UIImagePickerController()
        
        pickerController.delegate = self
        
        pickerController.sourceType = .camera
        
        pickerController.cameraCaptureMode = .photo
        
        present(pickerController, animated: true)
    }
    
    @objc func shortPressed(sender: UIButton) {
        
        let alertController = UIAlertController(title: "Voice Recognition", message: "Choose Language", preferredStyle: .alert)
        
        let enAction = UIAlertAction(title: "English", style: .default) { _ in
    
            self.speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
        }
        
        alertController.addAction(enAction)
        
        let twAction = UIAlertAction(title: "Chinese", style: .default) { _ in
        
            self.speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh-TW"))!
        }
        
        alertController.addAction(twAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UILongPressGestureRecognizer.State.began {
            
            print("began")
            
            voiceRecogniztion.tintColor = .red
            
            startRecording()
            
            isRecognizing = true
        }
        else if sender.state == UILongPressGestureRecognizer.State.ended {
            
            print("end")
            
            voiceRecogniztion.tintColor = .black
            
            audioEngine.stop()
            
            recognitionRequest?.endAudio()
            
            guard let text = searchTextField.text else { return }
            
            fetchMusicData(buttonTag: buttonTag, text: text)
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            
            recognitionTask?.cancel()
            
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.searchTextField.text = result?.bestTranscription.formattedString
                
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                
                self.audioEngine.stop()
                
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                
                self.recognitionTask = nil
                
            }
        })
        
        inputNode.removeTap(onBus: 0)
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            
            try audioEngine.start()
            
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
                
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            OperationQueue.main.addOperation() {
                self.voiceRecogniztion.isEnabled = isButtonEnabled
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.navigationItem.largeTitleDisplayMode = .always
        
    }
    
    func configureTextField() {
        
        searchTextField.clearButtonMode = .always
        
        searchTextField.leftViewMode = .always
        
        let searchView = UIImageView(frame: CGRect(x: 10, y: 0, width: 24, height: 24))
        
        let searchImage = UIImage(systemName: "magnifyingglass")
        
        searchView.image = searchImage
        
        searchView.tintColor = .black
        
        searchView.contentMode = .scaleAspectFit
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        
        view.addSubview(searchView)
        
        searchTextField.leftView = view
    }
    
    func configureButton() {
        
        buttonStackView.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        buttonStackView.isLayoutMarginsRelativeArrangement = true
        
        allButton.backgroundColor = K.Colors.customRed
        allButton.setTitle("All", for: .normal)
        allButton.setTitleColor(.white, for: .normal)
        allButton.cornerRadius = 15
        allButton.spinnerColor = .black
        allButton.layer.borderColor = K.Colors.customRed.cgColor
        allButton.layer.borderWidth = 2
        
        artistButton.backgroundColor = .white
        artistButton.setTitle("Artist", for: .normal)
        artistButton.setTitleColor(K.Colors.customRed, for: .normal)
        artistButton.cornerRadius = 15
        artistButton.spinnerColor = .black
        artistButton.layer.borderColor = K.Colors.customRed.cgColor
        artistButton.layer.borderWidth = 2
        
        songButton.backgroundColor = .white
        songButton.setTitle("Song", for: .normal)
        songButton.setTitleColor(K.Colors.customRed, for: .normal)
        songButton.cornerRadius = 15
        songButton.spinnerColor = .black
        songButton.layer.borderColor = K.Colors.customRed.cgColor
        songButton.layer.borderWidth = 2
        
        albumButton.backgroundColor = .white
        albumButton.setTitle("Album", for: .normal)
        albumButton.setTitleColor(K.Colors.customRed, for: .normal)
        albumButton.cornerRadius = 15
        albumButton.spinnerColor = .black
        albumButton.layer.borderColor = K.Colors.customRed.cgColor
        albumButton.layer.borderWidth = 2
    }
    
    func changeButtonColor(buttonTag: Int) {
        
        if buttonTag == allType {
            
            allButton.backgroundColor = K.Colors.customRed
            allButton.setTitleColor(.white, for: .normal)
            artistButton.setTitleColor(K.Colors.customRed, for: .normal)
            artistButton.backgroundColor = .white
            songButton.setTitleColor(K.Colors.customRed, for: .normal)
            songButton.backgroundColor = .white
            albumButton.setTitleColor(K.Colors.customRed, for: .normal)
            albumButton.backgroundColor = .white
        }
        else if buttonTag == artistType {
            
            allButton.setTitleColor(K.Colors.customRed, for: .normal)
            allButton.backgroundColor = .white
            artistButton.backgroundColor = K.Colors.customRed
            artistButton.setTitleColor(.white, for: .normal)
            songButton.setTitleColor(K.Colors.customRed, for: .normal)
            songButton.backgroundColor = .white
            albumButton.setTitleColor(K.Colors.customRed, for: .normal)
            albumButton.backgroundColor = .white
        }
        else if buttonTag == songType {
            
            allButton.setTitleColor(K.Colors.customRed, for: .normal)
            allButton.backgroundColor = .white
            artistButton.setTitleColor(K.Colors.customRed, for: .normal)
            artistButton.backgroundColor = .white
            songButton.backgroundColor = K.Colors.customRed
            songButton.setTitleColor(.white, for: .normal)
            albumButton.setTitleColor(K.Colors.customRed, for: .normal)
            albumButton.backgroundColor = .white
        }
        else if buttonTag == albumType {
            
            allButton.setTitleColor(K.Colors.customRed, for: .normal)
            allButton.backgroundColor = .white
            artistButton.setTitleColor(K.Colors.customRed, for: .normal)
            artistButton.backgroundColor = .white
            songButton.setTitleColor(K.Colors.customRed, for: .normal)
            songButton.backgroundColor = .white
            albumButton.backgroundColor = K.Colors.customRed
            albumButton.setTitleColor(.white, for: .normal)
        }
        
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        
        self.buttonTag = sender.tag
        
        changeButtonColor(buttonTag: sender.tag)
        
        guard let text = searchTextField?.text else {
            
            if buttonTag == allType {
                
                allButton.startAnimation()
                
                DispatchQueue.main.async {
                    
                    self.allButton.stopAnimation(animationStyle: .shake)
                }
            }
            else if buttonTag == artistType {
                
                artistButton.startAnimation()
                
                DispatchQueue.main.async {
                    
                    self.artistButton.stopAnimation(animationStyle: .shake)
                }
            }
            else if buttonTag == songType {
                
                songButton.startAnimation()
                
                DispatchQueue.main.async {
                    
                    self.songButton.stopAnimation(animationStyle: .shake)
                }
            }
            else if buttonTag == albumType {
                
                albumButton.startAnimation()
                
                DispatchQueue.main.async {
                    
                    self.albumButton.stopAnimation(animationStyle: .shake)
                }
            }
            
            return
        }
        
        fetchMusicData(buttonTag: buttonTag, text: text)
    }
    
    func configureSelectedData(state: Int, indexPath: IndexPath) {
        
        if state == allType {
            
            switch indexPath.section {
                
            case 0:
                
                configureSelectedData(state: artistType, indexPath: indexPath)
                
            case 1:
                
                configureSelectedData(state: songType, indexPath: indexPath)
                
            case 2:
                
                configureSelectedData(state: albumType, indexPath: indexPath)
                
            default:
                
                print("Unknown section type")
            }
            
        }
        else if state == artistType {
            if let songlistVC = self.storyboard?.instantiateViewController(withIdentifier: SongListViewController.storyboardID) as? SongListViewController {
                
                songlistVC.state = 3
                
                songlistVC.artistID = artists[indexPath.row].id
                
                songlistVC.artistInfo = artists[indexPath.row]
                
                songlistVC.artistURL = artists[indexPath.row].attributes?.url
                
                self.navigationController?.pushViewController(songlistVC, animated: true)
            }
        }
        else if state == songType {
            
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                
                var response = [SongsSearchInfo]()
                
                response.append(songs[indexPath.row])
                
                playSongVC.songs = response
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                present(playSongVC, animated: true)
                //self.navigationController?.pushViewController(playSongVC, animated: true)
            }
        }
        else if state == albumType {
            
            if let songlistVC = self.storyboard?.instantiateViewController(withIdentifier: SongListViewController.storyboardID) as? SongListViewController {
                
                songlistVC.state = 2
                
                songlistVC.albumID = albums[indexPath.row].id
                
                songlistVC.albumURL = albums[indexPath.row].attributes?.url
                
                songlistVC.albumInfo = albums[indexPath.row]
                
                self.navigationController?.pushViewController(songlistVC, animated: true)
            }
        }
    }
}

extension SearchDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if buttonTag == allType {
            
            guard !self.artists.isEmpty && !self.songs.isEmpty && !self.albums.isEmpty else { return "" }
            
            if section == 0 {
                
                return "Artists"
            }
            else if section == 1 {
                
                return "Songs"
            }
            else if section == 2 {
                
                return "Albums"
            }
        }
        
        return ""
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if buttonTag == allType {
            
            return 3
        }
        else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if buttonTag == allType {
            
            if section == 0 {
                
                return artists.count
            }
            else if section == 1 {
                
                return songs.count
            }
            else if section == 2 {
                
                return albums.count
            }
            
        }
        else if buttonTag == artistType {
            
            return artists.count
        }
        else if buttonTag == songType {
            
            return songs.count
        }
        else if buttonTag == albumType {
            
            return albums.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if buttonTag == allType {
            
            if indexPath.section == 0 {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchAllResultTableViewCell.identifier, for: indexPath) as? SearchAllResultTableViewCell else {
                    
                    fatalError("Cannot create search details cell")
                }
                
                cell.configureCellArtistsData(data: self.artists, indexPath: indexPath)
                
                cell.allImage.layer.cornerRadius = UIScreen.main.bounds.height / 7 / 2
                
                return cell
            }
            else if indexPath.section == 1 {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchAllResultTableViewCell.identifier, for: indexPath) as? SearchAllResultTableViewCell else {
                    
                    fatalError("Cannot create search details cell")
                }
                
                cell.configureCellSongsData(data: self.songs, indexPath: indexPath)
                
                cell.allImage.layer.cornerRadius = 0
                
                return cell
            }
            else if indexPath.section == 2 {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchAllResultTableViewCell.identifier, for: indexPath) as? SearchAllResultTableViewCell else {
                    
                    fatalError("Cannot create search details cell")
                }
                
                cell.configureCellAlbumsData(data: self.albums, indexPath: indexPath)
                
                cell.allImage.layer.cornerRadius = 0
                
                return cell
            }
            
        }
        
        else if buttonTag == artistType {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchArtistsResultTableViewCell.identifier, for: indexPath) as? SearchArtistsResultTableViewCell else {
                
                fatalError("Cannot create search details cell")
            }
            
            guard !self.artists.isEmpty else {
                
                return UITableViewCell()
                
            }
            
            cell.configureCellData(data: self.artists, indexPath: indexPath)
            
            return cell
            
        }
        else if buttonTag == songType {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchSongsResultTableViewCell.identifier, for: indexPath) as? SearchSongsResultTableViewCell else {
                
                fatalError("Cannot create search details cell")
            }
            
            guard !self.songs.isEmpty else {
                
                return UITableViewCell()
                
            }
            
            cell.configureCellData(data: self.songs, indexPath: indexPath)
            
            return cell
        }
        else if buttonTag == albumType {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchAlbumsResultTableViewCell.identifier, for: indexPath) as? SearchAlbumsResultTableViewCell else {
                
                fatalError("Cannot create search details cell")
            }
            
            guard !self.albums.isEmpty else {
                
                return UITableViewCell()
                
            }
            
            cell.configureCellData(data: self.albums, indexPath: indexPath)
            
            return cell
        }
        
        return UITableViewCell()
        
    }
    
}

extension SearchDetailsViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        guard let text = textField.text else {
            
            return
            
        }
        
        fetchMusicData(buttonTag: buttonTag, text: text)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let text = textField.text else { return }
        
        fetchMusicData(buttonTag: buttonTag, text: text)
    }
}

extension SearchDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        configureSelectedData(state: buttonTag, indexPath: indexPath)
        
    }
}

extension SearchDetailsViewController {
    
    func fetchMusicData(buttonTag: Int, text: String) {
        
        MusicManager.sharedInstance.stopAllSessions()
        
        if buttonTag == allType {
            
            fetchAllTypes(text: text)
        }
        else if buttonTag == artistType {
            
            fetchArtists(text: text)
        }
        
        else if buttonTag == songType {
            
            fetchSongs(text: text)
        }
        else if buttonTag == albumType {
            
            fetchAlbums(text: text)
        }
    }
    
    func fetchAllTypes(text: String) {
        
        MusicManager.sharedInstance.searchArtists(term: text, limit: 10) { artists in
            
            self.artists = []
            
            self.artists = artists
            
            MusicManager.sharedInstance.searchSongs(term: text, limit: 10) { songs in
                
                self.songs = []
                
                self.songs = songs
                
                MusicManager.sharedInstance.searchAlbums(term: text, limit: 10) { albums in
                    
                    self.albums = []
                    
                    self.albums = albums
                    
                    DispatchQueue.main.async {
                        
                        self.searchDetailsTableView.reloadData()
                    }
                }
            }
        }
    }
    
    func fetchSongs(text: String) {
        
        MusicManager.sharedInstance.searchSongs(term: text, limit: 25) { songs in
            
            self.songs = []
            
            self.songs = songs
            
            DispatchQueue.main.async {
                
                self.searchDetailsTableView.reloadData()
                
            }
        }
        
    }
    
    func fetchArtists(text: String) {
        
        MusicManager.sharedInstance.searchArtists(term: text, limit: 25) { artists in
            
            self.artists = []
            
            self.artists = artists
            
            DispatchQueue.main.async {
                
                self.searchDetailsTableView.reloadData()
            }
        }
        
    }
    
    func fetchAlbums(text: String) {
        
        MusicManager.sharedInstance.searchAlbums(term: text, limit: 25) { albums in
            
            self.albums = []
            
            self.albums = albums
            
            DispatchQueue.main.async {
                
                self.searchDetailsTableView.reloadData()
            }
        }
    }
}

extension SearchDetailsViewController: SFSpeechRecognizerDelegate {
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print(available)
        if available {
            
            voiceRecogniztion.tintColor = .red
            
        }
        else {
            
            audioEngine.stop()
            
            voiceRecogniztion.tintColor = .black
        }
    }
}

extension SearchDetailsViewController: UIPickerViewDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true)
        
        activityIndicatorView.center = self.view.center
        
        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        
        activityIndicatorView.tintColor = .black
        
        activityIndicatorView.center = self.view.center
        
        self.view.addSubview(activityIndicatorView)
        
        activityIndicatorView.startAnimating()
        
        self.activityIndicatorView.isHidden = false
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("couldn't load image from Photos")
        }
        
        let celebImage: Data = image.jpegData(compressionQuality: 0.2)!
        
        sendImageToRekognition(celebImageData: celebImage, image: image)
    }
}


//MARK: - rekognition method
extension SearchDetailsViewController {
    
    func sendImageToRekognition(celebImageData: Data, image: UIImage) {
        
        rekognitionObject = AWSRekognition.default()
        
        let celebImageAWS = AWSRekognitionImage()
        
        celebImageAWS?.bytes = celebImageData
        
        let celebRequest = AWSRekognitionRecognizeCelebritiesRequest()
        
        celebRequest?.image = celebImageAWS
        
        rekognitionObject?.recognizeCelebrities(celebRequest!) { (result, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            guard let result = result, let celebrityFaces = result.celebrityFaces else { return }
            
            if !celebrityFaces.isEmpty {
                
                for celebFace in celebrityFaces {
                    
                    guard let matchNumber = celebFace.matchConfidence else {
                        return
                    }

                    if matchNumber.intValue > 50 {
                        
                        DispatchQueue.main.async {
                            
                            self.activityIndicatorView.stopAnimating()
                            
                            self.activityIndicatorView.isHidden = true
                            
                            let alert = UIAlertController(title: celebFace.name, message: "", preferredStyle: .alert)
                            
                            alert.addImage(image: image)
                           
                            let search = UIAlertAction(title: "Search", style: .default, handler: { _ in
                                
                                self.searchTextField.text = celebFace.name
                                
                                guard let text = self.searchTextField.text else { return }
                                
                                self.fetchMusicData(buttonTag: self.buttonTag, text: text)
                    
                            })
                            
                            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                            
                            alert.addAction(search)
                            
                            alert.addAction(cancel)
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
            else {
    
                print("No faces in this pic")
                
                DispatchQueue.main.async {
                    
                    self.activityIndicatorView.stopAnimating()
                    
                    self.activityIndicatorView.isHidden = true
                    
                    let alert = UIAlertController(title: "Not Found", message: "Please take a picture again", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    let imgViewTitle = UIImageView(frame: CGRect(x: 10, y: 10, width: UIScreen.main.bounds.width / 3 * 2, height: UIScreen.main.bounds.height / 3 * 2))
                    
                    imgViewTitle.image = image
                    
                    alert.view.addSubview(imgViewTitle)
                    
                    alert.addAction(cancel)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
    }
}
