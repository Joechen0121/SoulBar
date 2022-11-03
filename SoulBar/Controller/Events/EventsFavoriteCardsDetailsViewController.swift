//
//  EventsFavoriteCardsDetailsViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/3.
//

import UIKit
import MapKit

class EventsFavoriteCardsDetailsViewController: UIViewController {

    var eventsFavorite: FirebaseEventsData?
    
    @IBOutlet weak var eventsLocation: UILabel!
    
    @IBOutlet weak var eventsMap: MKMapView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var eventLocation: UIButton!
    
    let annotation = MKPointAnnotation()
    
    var isFavorite = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureEventLocation()

        eventLocation.layer.cornerRadius = eventLocation.frame.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureButton()
    }
    
    @IBAction func locateEvent(_ sender: Any) {
        
        eventsMap.setRegion(MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: true)
    }
    
    @IBAction func buyTicketButton(_ sender: UIButton) {
        
        guard let eventsFavorite = eventsFavorite else {
            return
        }
        
        if let url = URL(string: eventsFavorite.webURL) {
            
            if UIApplication.shared.canOpenURL(url) {

                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    @IBAction func gotToChatroom(_ sender: UIButton) {
        print("Got to chatroom")
    }
    
    @IBAction func addToFavorite(_ sender: UIButton) {
        
        guard let eventsFavorite = eventsFavorite else {
            return
        }
        
        if isFavorite {
    
            FirebaseEventsManager.sharedInstance.removeEventsTypeData(with: eventsFavorite.type, uid: eventsFavorite.uid)
            
            self.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
            
            isFavorite = false

        }
        else {
            
            FirebaseEventsManager.sharedInstance.addEventsTypeData(with: eventsFavorite.type, uid: eventsFavorite.uid, webURL: eventsFavorite.webURL, eventName: eventsFavorite.eventTime, eventTime: eventsFavorite.eventTime, location: eventsFavorite.location, url: eventsFavorite.url, chatroom: eventsFavorite.uid)
                
            self.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            
            isFavorite = true

        }

    }
    
    func configureEventLocation() {
        
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
    
    func configureButton() {
        
        
        guard let eventsFavorite = eventsFavorite else {
            return
        }
        
        FirebaseEventsManager.sharedInstance.fetchEventsTypeData(with: eventsFavorite.type) { result in
            
            result.forEach { event in
                
                if eventsFavorite.uid == event.uid {
                    
                    self.isFavorite = true
                }
            }
            
            DispatchQueue.main.async {

                if self.isFavorite {

                    DispatchQueue.main.async {
                        
                        self.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    }
                    
                }
                else {
                    
                    DispatchQueue.main.async {
                        
                        self.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    }
                }
            }
        }
        
    }
    
}
