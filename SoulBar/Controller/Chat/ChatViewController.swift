//
//  ChatViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/4.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var chatTableView: UITableView!
    
    @IBOutlet weak var eventTime: UILabel!
    
    @IBOutlet weak var eventLocation: UILabel!
    
    @IBOutlet weak var sendMessageButton: UIButton!

    @IBOutlet weak var messageTextField: UITextField!
    
    static let storyboardID = "ChatVC"
    
    var eventsFavorite: FirebaseEventsData?
    
    var messages = [ChatroomMessagesData]()
    
    var testName = "test"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatTableView.register(UINib.init(nibName: ChatMessageStrangerTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ChatMessageStrangerTableViewCell.identifier)

        chatTableView.register(UINib.init(nibName: ChatMessageOwnerTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ChatMessageOwnerTableViewCell.identifier)
        
        chatTableView.dataSource = self
        
        chatTableView.separatorStyle = .none
        
        configureInformation()
        
        guard let eventsFavorite = eventsFavorite else {
            
            return
        }
        
        //configureMessageData()
        
        FirebaseChatroomManager.sharedInstance.addChatroomMembersData(chatroomID: eventsFavorite.uid, uuid: testName)

        addChatroomListener(chatroomID: eventsFavorite.uid)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.messages = []
    }
    
    func configureMessageData() {
        
        guard let eventsFavorite = eventsFavorite else {
            
            return
        }
        
        self.messages = []

        FirebaseChatroomManager.sharedInstance.fetchChatroomMessagesData(with: eventsFavorite.uid) { result in
            
            result.forEach { message in

                self.messages.append(message)

            }
    
            DispatchQueue.main.async {
                
                self.chatTableView.reloadData()
            }
        }
    }
    
    func addChatroomListener(chatroomID: String) {
        
        var data = [ChatroomMessagesData]()

        self.messages = []
        
        FirebaseChatroomManager.sharedInstance.chatroomDB.document(chatroomID).collection("messages").order(by: "time").addSnapshotListener { snapshot, error in

            if let e = error {
                
                print("There was an issue retrieving data from Firebase, \(e)")
                
            } else {
                
                data = []
                
                guard let snapshot = snapshot else { return }
                
                snapshot.documents.forEach { snapshot in
                    
                    guard let dataPath = try? snapshot.data(as: ChatroomMessagesData.self) else { return }
                    
                    data.append(dataPath)
    
                }
                
                self.messages = []
                
                self.messages = data

                DispatchQueue.main.async {

                    self.chatTableView.reloadData()
                    
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                        
                    if let _ = self.chatTableView.cellForRow(at: indexPath) {
                        
                        self.chatTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    }
                }
            }
        }
        
    }
    
    @IBAction func sendMessages(_ sender: UIButton) {
        
        guard let text = messageTextField.text else { return }
        
        guard let eventsFavorite = eventsFavorite else { return }

        FirebaseChatroomManager.sharedInstance.addChatroomMessagesData(chatroomID: eventsFavorite.uid, messageID: UUID().uuidString, sender: self.testName, content: text, contentType: 0)

        DispatchQueue.main.async {
            
            self.messageTextField.text = ""
        }
        
    }
    
    func configureInformation() {
        
        guard let eventsFavorite = eventsFavorite else {
            return
        }
        
        eventTime.text = eventsFavorite.eventTime
        
        eventLocation.text = eventsFavorite.location
    }

}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if messages[indexPath.row].sender == testName {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageOwnerTableViewCell.identifier, for: indexPath) as? ChatMessageOwnerTableViewCell else {
                
                fatalError("Cannot create message cell")
            }
           
            cell.messageLabel.text = messages[indexPath.row].content
 
            return cell
        }
        else {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageStrangerTableViewCell.identifier, for: indexPath) as? ChatMessageStrangerTableViewCell else {
                
                fatalError("Cannot create message cell")
            }
            
            cell.messageLabel.text = messages[indexPath.row].content

            return cell
        }
    }
}
