//
//  EventsViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import UIKit

class EventsViewController: UIViewController {
    
    let eventsManager = EventsManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventsManager.getMusicEventsInformation(category: MusicEventsCategory.演唱會) { result in
            print(result)
        }
    }
    
}
