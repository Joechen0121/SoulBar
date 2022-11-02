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
    
    var events: MusicEvents?
    
    let annotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureEventLocation()

    }
    @IBAction func buyTicketButton(_ sender: UIButton) {
        
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
    
    @IBAction func addChatroomButton(_ sender: UIButton) {
        
        print("Add chatroom")
    }
    
    func configureEventLocation() {
        
        guard let events = events else {
            return
        }
        
        locationLabel.text = events.showInfo[0].location
        
        MapManager.sharedInstance.coordinates(forAddress: events.showInfo[0].location) { result in
            
            guard let result = result else { return }
            
            self.eventMap.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude), latitudinalMeters: 1000, longitudinalMeters: 1000)
            
            self.annotation.title = "Event Location"
            
            self.annotation.coordinate = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)

            self.eventMap.addAnnotation(self.annotation)
            
        }
    }
}
