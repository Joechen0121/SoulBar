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
    
    @IBOutlet weak var eventsFavoriteCollectionView: UICollectionView!
    
    let eventsManager = EventsManager()
    
    var events = [MusicEvents]()
    
    var eventsFavorite: [FirebaseEventsData]?
    
    var favoriteCount = 0
    
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventsTableView.dataSource = self
        
        eventsTableView.showsVerticalScrollIndicator = false
        
        eventsTableView.showsHorizontalScrollIndicator = false
        
        eventsFavoriteCollectionView.dataSource = self
        
        eventsFavoriteCollectionView.showsVerticalScrollIndicator = false
        
        eventsFavoriteCollectionView.showsHorizontalScrollIndicator = false
        
        configureCollectionLayout()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        eventsManager.getMusicEventsInformation(category: MusicEventsCategory.演唱會) { result in
            
            self.events = result
            
            DispatchQueue.main.async {
                
                self.eventsTableView.reloadData()
            }
        }
        
        configureEventsFavoriteData()
    }

    func configureCollectionLayout() {
        
        let flowlayout = UICollectionViewFlowLayout()
        
        flowlayout.itemSize = CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2 / 5 * 6)
        
        flowlayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        flowlayout.scrollDirection = .horizontal
        
        eventsFavoriteCollectionView.setCollectionViewLayout(flowlayout, animated: true)
        
    }
    
    func configureEventsFavoriteData() {
        
        if KeychainManager.sharedInstance.id == nil {
            
            self.collectionHeight.constant = 0
            
            self.view.layoutIfNeeded()
            
            return
        }

        FirebaseEventsManager.sharedInstance.fetchEventsTypeData(with: MusicEventsCategory.演唱會.rawValue) { result in
            
            self.eventsFavorite = result
            
            self.favoriteCount = result.count
            
            if result.isEmpty {
                
                let height = self.eventsFavoriteCollectionView.collectionViewLayout.collectionViewContentSize.height
            
                self.collectionHeight.constant = 0
                
                self.view.layoutIfNeeded()
            }
            else {
                
                self.collectionHeight.constant = UIScreen.main.bounds.width / 2 / 5 * 6
    
            }
            
            DispatchQueue.main.async {
                
                self.eventsFavoriteCollectionView.reloadData()
            }
        }
    }
}

extension EventsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Events Information"

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return events.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventsTableViewCell.identifier, for: indexPath) as? EventsTableViewCell else {
            
            fatalError("Cannot create event cells")
        }
        
        cell.cardsView.backgroundColor = UIColor(red: 169 / 255, green: 164 / 255, blue: 228 / 255, alpha: 1)
        // cell.cardsView.icon = UIImage(systemName: "music.quarternote.3")
        cell.cardsView.icon = UIImage(named: "44")
        cell.cardsView.titleSize = 17
        cell.cardsView.title = events[indexPath.row].title
        cell.cardsView.itemTitle = events[indexPath.row].startDate
        cell.cardsView.itemSubtitle = events[indexPath.row].comment
        cell.cardsView.textColor = UIColor.white
        cell.cardsView.hasParallax = true
        cell.widthConstraint.constant = UIScreen.main.bounds.width / 2

        if let cardContent = storyboard?.instantiateViewController(withIdentifier: "CardContent") as? EventsCardsDetailsViewController {

            cardContent.events = events[indexPath.row]
            
            cell.cardsView.shouldPresent(cardContent, from: self, fullscreen: true)
        }
        
        return cell
        
    }
}

extension EventsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return eventsFavorite?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventsFavoriteCollectionViewCell.identifier, for: indexPath) as? EventsFavoriteCollectionViewCell else {
            
            fatalError("Cannot create event cells")
        }
        
        guard let eventsFavorite = eventsFavorite else { return UICollectionViewCell() }
        
        cell.favoriteCards.backgroundColor = K.Colors.customRed
        cell.favoriteCards.icon = UIImage(named: "43")
        cell.favoriteCards.icon?.withTintColor(.gray)
        cell.favoriteCards.titleSize = 17
        cell.favoriteCards.title = eventsFavorite[indexPath.row].eventName
        cell.favoriteCards.itemTitle = eventsFavorite[indexPath.row].eventTime
        cell.favoriteCards.itemSubtitle = ""
        cell.favoriteCards.textColor = UIColor.white
        cell.favoriteCards.hasParallax = true

        if let cardContent = storyboard?.instantiateViewController(withIdentifier: "CardFavoriteContent") as? EventsFavoriteCardsDetailsViewController {
    
            cardContent.eventsFavorite = eventsFavorite[indexPath.row]
            
            cell.favoriteCards.shouldPresent(cardContent, from: self, fullscreen: true)
        }

        return cell
    }
}
