//
//  EventsViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import UIKit
import MapKit
import CarPlay
import Cards

class EventsViewController: UIViewController {
    
    @IBOutlet weak var eventsTableView: UITableView!
    
    let eventsManager = EventsManager()
    
    var events = [MusicEvents]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventsTableView.dataSource = self
        
        eventsTableView.delegate = self
        
        eventsManager.getMusicEventsInformation(category: MusicEventsCategory.演唱會) { result in
            print(result)
            
            self.events = result
            
            DispatchQueue.main.async {
                
                self.eventsTableView.reloadData()
            }
        }
    }
    
}

extension EventsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventsTableViewCell.identifier, for: indexPath) as? EventsTableViewCell else {
            
            fatalError("Cannot create event cells")
        }
        
        cell.cardsView.backgroundColor = UIColor(red: 0, green: 94/255, blue: 112/255, alpha: 1)
        cell.cardsView.icon = UIImage(systemName: "pause")
        cell.cardsView.titleSize = 17
        cell.cardsView.title = events[indexPath.row].title
        cell.cardsView.itemTitle = events[indexPath.row].startDate
        cell.cardsView.itemSubtitle = events[indexPath.row].comment
        cell.cardsView.textColor = UIColor.white
        cell.cardsView.hasParallax = true
        
        if let cardContent = storyboard?.instantiateViewController(withIdentifier: "CardContent") as? EventsCardsDetailsViewController {
            
            cardContent.events = events[indexPath.row]
            
            cell.cardsView.shouldPresent(cardContent, from: self, fullscreen: true)
        }
        
        return cell
        
    }
}

extension EventsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
}
