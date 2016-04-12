//
//  MainVC.swift
//  Cheers
//
//  Created by Xavier Ramirez on 3/16/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import QuartzCore
import Alamofire

class MainVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var offMessage: UILabel!
    @IBOutlet weak var userStatus: UISwitch!
    @IBOutlet weak var userStatusImage: UIImageView!
    @IBOutlet weak var friendsList: UITableView!
    @IBOutlet weak var logout: UIButton!
    @IBOutlet weak var settings: UIButton!
    
    var user:UserDelegateProtocol?
    var loggedInUser:String!
    var checkStatus:Bool?=nil
    var password:String!
    var parameters:[String: AnyObject] = [String:AnyObject]()
    var friends:[String]?=nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userStatus.setOn(self.user!.isActive(), animated: true)
        if self.user!.isActive() {
            userStatusImage.image = UIImage(named: "Cheers-Logo")
            friendsList.hidden = false
            offMessage.hidden = true
        }
        else {
            userStatusImage.image = UIImage(named: "Cheers-Logo-Transparent")
            friendsList.hidden = true
            offMessage.hidden = false
        }
        
        //Rounding UI elements
        self.offMessage.layer.masksToBounds = true
        self.offMessage.layer.cornerRadius = 12.0
        
        self.logout.layer.masksToBounds = true
        self.logout.layer.cornerRadius = 7.0
        
        self.settings.layer.masksToBounds = true
        self.settings.layer.cornerRadius = 7.0
        
        
        // Instantiates static data model
        //self.loadDataModel()
        
        
        // Cuts extra footer
        friendsList.tableFooterView = UIView()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    ///statusChange
    /// alters the state of UITableView or Label to hidden
    /// based on the userStatus boolean value
    @IBAction func statusChange(sender: AnyObject) {
        self.user!.switchStatus()
        
        // Changes the status image and show or hide table view
        if self.user!.isActive() {
            userStatusImage.image = UIImage(named: "Cheers-Logo")
            friendsList.hidden = false
            offMessage.hidden = true
        }
        else {
            userStatusImage.image = UIImage(named: "Cheers-Logo-Transparent")
            friendsList.hidden = true
            offMessage.hidden = false
        }
        let parameters:[String:AnyObject] = [
            "username" : self.user!.getUsername(),
            "status" : self.user!.isActive()
        ]
        //ideally this would be an async request
        Alamofire.request(.POST, "https://morning-crag-80115.herokuapp.com/update_status", parameters: parameters,encoding:.JSON)
    }
    
    ///numberOfSectionsInTableView
    /// returns the number of sections
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    ///numberOfRowsInSection
    /// returns the number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.user!.getFriendsList().count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendsTableViewCell
        let list = Array(self.user!.getFriendsList().keys)
        let friend = list[indexPath.row]
        cell.nameLabel.text = friend
        
        //render correct image based on friend's status
        if self.user!.friendIsActive(friend){
            cell.statusIcon.image = UIImage(named: "Cheers-Logo")
        }
        else {
            cell.statusIcon.image = UIImage(named: "Cheers-Logo-Transparent")
        }
        return cell
    }
    
    
    //prepare for segue for add friends
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toAddFriend") {
            let addFriendVC = segue.destinationViewController as! addFriends
            addFriendVC.user = self.user
        }
        else if(segue.identifier == "toSetting") {
            let setting = segue.destinationViewController as! settingsVC
            setting.user = self.user
        }else if(segue.identifier == "AddDrink"){
            let AddDrinkEventVC = segue.destinationViewController as! CreateDrinkEventVC
            AddDrinkEventVC.userDelegate = user
        }
    }
    
}
