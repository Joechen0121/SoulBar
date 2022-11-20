//
//  ProfileEventsViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/16.
//

import UIKit

class ProfileEventsViewController: UIViewController {

    static let storyboardID = "ProfileEventsVC"
    
    @IBOutlet weak var eventCollectionView: UICollectionView!
    
    var activityIndicatorView = UIActivityIndicatorView()
    
    var eventsFavorite = [FirebaseEventsData]()
    
    var favoriteCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        eventCollectionView.dataSource = self
        
        configureCellSize()
        
        self.navigationItem.title = "My Events"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        
        activityIndicatorView.tintColor = .black
        
        activityIndicatorView.center = self.view.center
        
        self.view.addSubview(activityIndicatorView)
        
        activityIndicatorView.startAnimating()
        
        activityIndicatorView.isHidden = false
        
        configureEventsFavoriteData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    func configureCellSize() {
        
        let itemSpace: Double = 3
        
        let columnCount: Double = 2
        
        let flowlayout = UICollectionViewFlowLayout()
        
        let width = floor((UIScreen.main.bounds.width - itemSpace * (columnCount - 1)) / columnCount)
        
        flowlayout.itemSize = CGSize(width: width, height: width)
    
        flowlayout.estimatedItemSize = .zero
        
        flowlayout.minimumInteritemSpacing = itemSpace
        
        flowlayout.minimumLineSpacing = itemSpace
        
        self.eventCollectionView.setCollectionViewLayout(flowlayout, animated: true)
        
    }
    
    func configureEventsFavoriteData() {

        FirebaseEventsManager.sharedInstance.fetchEventsTypeData(with: MusicEventsCategory.演唱會.rawValue) { result in
            
            self.eventsFavorite = result
            
            DispatchQueue.main.async {
                
                self.eventCollectionView.reloadData()
                
                self.activityIndicatorView.isHidden = true
            }
        }
    }

}

extension ProfileEventsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return eventsFavorite.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: ProfileEventCollectionViewCell.identifier, for: indexPath) as? ProfileEventCollectionViewCell else {
            
            fatalError("Cannot create event cells")
        }
        
        cell.eventCard.backgroundColor = UIColor(red: 249/255, green: 68/255, blue: 73/255, alpha: 1)
        
        let image = UIImage(systemName: "heart")
        let heartImage = image?.withTintColor(.white, renderingMode: .alwaysOriginal)
        cell.eventCard.icon = heartImage
        cell.eventCard.titleSize = 17
        cell.eventCard.title = eventsFavorite[indexPath.row].eventName
        cell.eventCard.itemTitle = eventsFavorite[indexPath.row].eventTime
        cell.eventCard.itemSubtitle = ""
        cell.eventCard.textColor = UIColor.white
        cell.eventCard.hasParallax = true

        if let cardContent = storyboard?.instantiateViewController(withIdentifier: "CardFavoriteContent") as? EventsFavoriteCardsDetailsViewController {

            cardContent.eventsFavorite = eventsFavorite[indexPath.row]
            
            cell.eventCard.shouldPresent(cardContent, from: self, fullscreen: true)
        }
        
        return cell
    }
}
