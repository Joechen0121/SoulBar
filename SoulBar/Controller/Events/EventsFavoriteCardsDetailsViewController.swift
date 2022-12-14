//
//  EventsFavoriteCardsDetailsViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/3.
//

import UIKit
import MapKit

class EventsFavoriteCardsDetailsViewController: UIViewController {
    
    @IBOutlet weak var eventsLocation: UILabel!
    
    @IBOutlet weak var eventsMap: MKMapView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var eventLocation: UIButton!
    
    @IBOutlet weak var ticketImage: UIImageView!
    
    @IBOutlet weak var chatroomImage: UIImageView!
    
    @IBOutlet weak var favoriteImage: UIImageView!
    
    var eventsFavorite: FirebaseEventsData?
    
    let annotation = MKPointAnnotation()
    
    var isFavorite = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureEventLocation()
        
        eventLocation.layer.cornerRadius = eventLocation.frame.height / 2
        
        configureTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureButton()
    }
    
    private func configureTapGesture() {
        
        let ticketTap = UITapGestureRecognizer(target: self, action: #selector(buyTicketButton))
        
        ticketImage.isUserInteractionEnabled = true
        
        ticketImage.addGestureRecognizer(ticketTap)
        
        let chatroomTap = UITapGestureRecognizer(target: self, action: #selector(gotToChatroom))
        
        chatroomImage.isUserInteractionEnabled = true
        
        chatroomImage.addGestureRecognizer(chatroomTap)
        
        let favoriteTap = UITapGestureRecognizer(target: self, action: #selector(addToFavorite))
        
        favoriteImage.isUserInteractionEnabled = true
        
        favoriteImage.addGestureRecognizer(favoriteTap)
    }
    
    @IBAction func locateEvent(_ sender: Any) {
        
        eventsMap.setRegion(MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: true)
    }
    
    @objc func buyTicketButton() {
        
        guard let eventsFavorite = eventsFavorite else {
            return
        }
        
        if let url = URL(string: eventsFavorite.webURL) {
            
            if UIApplication.shared.canOpenURL(url) {
                
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    @objc func gotToChatroom() {
        
        if let chatVC = self.storyboard?.instantiateViewController(withIdentifier: ChatViewController.storyboardID) as? ChatViewController {
            
            chatVC.eventsFavorite = eventsFavorite
            
            present(chatVC, animated: true)
            
        }
    }
    
    @objc func addToFavorite() {
        
        guard let eventsFavorite = eventsFavorite else {
            return
        }
        
        if isFavorite {
            
            FirebaseEventsManager.sharedInstance.removeEventsTypeData(with: eventsFavorite.type, uid: eventsFavorite.uid)
            
            self.favoriteImage.image = UIImage(systemName: "heart.circle")
            
            self.favoriteImage.tintColor = UIColor.lightGray
            
        }
        else {
            
            FirebaseEventsManager.sharedInstance.addEventsTypeData(with: eventsFavorite.type, uid: eventsFavorite.uid, webURL: eventsFavorite.webURL, eventName: eventsFavorite.eventTime, eventTime: eventsFavorite.eventTime, location: eventsFavorite.location, url: eventsFavorite.url, chatroom: eventsFavorite.uid)
            
            self.favoriteImage.image = UIImage(systemName: "heart.circle.fill")
            
            self.favoriteImage.tintColor = K.Colors.customRed
            
        }
        
        isFavorite.toggle()
    }
    
    private func configureEventLocation() {
        
        guard let eventsFavorite = eventsFavorite else {
            return
        }
        
        eventsLocation.text = eventsFavorite.location
        
        MapManager.sharedInstance.coordinates(forAddress: eventsFavorite.location) { result in
            
            guard let result = result else { return }
            
            self.eventsMap.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude), latitudinalMeters: 1000, longitudinalMeters: 1000)
            
            self.annotation.title = "Event Location"
            
            self.annotation.coordinate = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)
            
            self.eventsMap.addAnnotation(self.annotation)
            
        }
    }
    
    private func configureButton() {
        
        if KeychainManager.sharedInstance.id == nil {
            if let authVC = storyboard?.instantiateViewController(withIdentifier: AppleAuthViewController.storyboardID) as? AppleAuthViewController {
                
                authVC.modalPresentationStyle = .overCurrentContext
                
                self.present(authVC, animated: false)
                
                return
            }
        }
        
        guard let eventsFavorite = eventsFavorite else {
            return
        }
        
        FirebaseEventsManager.sharedInstance.fetchEventsTypeData(with: eventsFavorite.type) { result in
            
            result.forEach { event in
                
                if eventsFavorite.uid == event.uid {
                    
                    self.isFavorite = true
                }
            }
            
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
