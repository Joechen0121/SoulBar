//
//  EventsViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import UIKit

class EventsViewController: UIViewController {
    
    @IBOutlet weak var eventsTableView: UITableView!
    
    let eventsManager = EventsManager()
    
    var events = [MusicEvents]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventsTableView.dataSource = self
        
//        eventsManager.getMusicEventsInformation(category: MusicEventsCategory.演唱會) { result in
//            print(result)
//            
//            self.events = result
//            
//            DispatchQueue.main.async {
//                
//                self.eventsTableView.reloadData()
//            }
//        }
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
//        
//        cell.eventImage =
        cell.eventName.text = events[indexPath.row].title
        cell.eventDate.text = events[indexPath.row].showInfo[0].time
        cell.eventPlace.text = events[indexPath.row].showInfo[0].location
        
        return cell
    }
    
    
    
}
