//
//  EventsCardsDetailsViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/1.
//

import UIKit
import MapKit

class EventsCardsDetailsViewController: UIViewController {
    
    @IBOutlet weak var eventMap: MKMapView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var favoriteImage: UIImageView!
    
    @IBOutlet weak var linkImage: UIImageView!
    
    var events: MusicEvents?
    
    var isFavorite = false
    
    let annotation = MKPointAnnotation()
    
    @IBOutlet weak var eventLocation: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureEventLocation()
        
        eventLocation.layer.cornerRadius = eventLocation.frame.height / 2
        
        let favoriteTap = UITapGestureRecognizer(target: self, action: #selector(addToFavorite))
        
        favoriteImage.isUserInteractionEnabled = true
        
        favoriteImage.addGestureRecognizer(favoriteTap)
        
        let linkTap = UITapGestureRecognizer(target: self, action: #selector(buyTicketButton))
        
        linkImage.isUserInteractionEnabled = true
        
        linkImage.addGestureRecognizer(linkTap)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureButton()
    }
                                                                 
    func configureButton() {
        
        if KeychainManager.sharedInstance.id == nil { return }
        
        guard let events = events, let type = events.type else {
            return
        }
        
        FirebaseEventsManager.sharedInstance.fetchEventsTypeData(with: type) { result in
            
            result.forEach { event in
                
                if events.UID == event.uid {
                    
                    self.isFavorite = true
                }
            }
            
            DispatchQueue.main.async {

                if self.isFavorite {

                    DispatchQueue.main.async {
                        
                        self.favoriteImage.image = UIImage(systemName: "heart.circle.fill")
                        
                        self.favoriteImage.tintColor = K.Colors.customRed
                    }
                    
                }
                else {
                    
                    DispatchQueue.main.async {
                        
                        self.favoriteImage.image = UIImage(systemName: "heart.circle")
                        
                        self.favoriteImage.tintColor = UIColor.lightGray
                    }
                }
            }
        }
        
    }
    
    @objc func addToFavorite() {
        
        if KeychainManager.sharedInstance.id == nil {
            let authVC = storyboard!.instantiateViewController(withIdentifier: AppleAuthViewController.storyboardID) as! AppleAuthViewController
            authVC.modalPresentationStyle = .overCurrentContext
            self.present(authVC, animated: false)
            
            return
        }
        
        guard let events = events, let type = events.type, let url = events.url, let location = events.showInfo[0].location else {
            return
        }
        
        if isFavorite {
    
            FirebaseEventsManager.sharedInstance.removeEventsTypeData(with: type, uid: events.UID)
            
            self.favoriteImage.image = UIImage(systemName: "heart.circle")
            
            self.favoriteImage.tintColor = UIColor.lightGray
            
            isFavorite = false

        }
        else {
            
            FirebaseEventsManager.sharedInstance.addEventsTypeData(with: type, uid: events.UID, webURL: events.webSales, eventName: events.title, eventTime: events.startDate, location: location, url: url, chatroom: events.UID)
                
            self.favoriteImage.image = UIImage(systemName: "heart.circle.fill")
            
            self.favoriteImage.tintColor = K.Colors.customRed
            
            isFavorite = true

        }

        
    }
    
    @objc func buyTicketButton() {
        
        print("buy")
        
        guard let events = events else {
            return
        }
        
        if let url = URL(string: events.webSales) {
            
            if UIApplication.shared.canOpenURL(url) {

                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }

    }
    
    @IBAction func locateEvents(_ sender: Any) {
        
        eventMap.setRegion(MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: true)
    }
    
    @IBAction func addChatroomButton(_ sender: UIButton) {
        
        print("Add chatroom")
    }
    
    func configureEventLocation() {
        
        guard let events = events else {
            return
        }
        
        print(events.showInfo.count)
        
        guard !events.showInfo.isEmpty, events.showInfo[0].location != nil else {
            
            locationLabel.text = "None"
            
            return
            
        }
        
        locationLabel.text = events.showInfo[0].location
        
        MapManager.sharedInstance.coordinates(forAddress: events.showInfo[0].location!) { result in
            
            guard let result = result else { return }
            
            self.eventMap.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude), latitudinalMeters: 1000, longitudinalMeters: 1000)
            
            self.annotation.title = "Event Location"
            
            self.annotation.coordinate = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)

            self.eventMap.addAnnotation(self.annotation)
         
        }
    }
}
