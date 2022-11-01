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
    
    var events: MusicEvents?
    
    let annotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureEventLocation()

    }
    @IBAction func buyTicketButton(_ sender: UIButton) {
        
        print("buy")
    }
    
    @IBAction func addChatroomButton(_ sender: UIButton) {
        
        print("Add chatroom")
    }
    
    func configureEventLocation() {
        
        guard let events = events else {
            return
        }
        
        MapManager.sharedInstance.coordinates(forAddress: events.showInfo[0].location) { result in
            
            guard let result = result else { return }
            
            self.eventMap.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude), latitudinalMeters: 1000, longitudinalMeters: 1000)
            
            self.annotation.title = "Event Location"
            
            self.annotation.coordinate = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)

            self.eventMap.addAnnotation(self.annotation)
            
        }
    }
}
