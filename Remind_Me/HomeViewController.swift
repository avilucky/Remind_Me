//
//  HomeViewController.swift
//  Remind_Me
//
//  Created by Avinash Talreja on 10/29/16.
//  Copyright © 2016 Avinash Talreja. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,CNContactPickerDelegate {

    @IBOutlet weak var homeViewTable: UITableView!
    var reminders: [Reminder] = []
    var indexNum:Int = 0
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("view load home view controller")
        
        homeViewTable.dataSource = self
        homeViewTable.delegate = self
        
        defaults.set(0, forKey: "index")

        updateActiveReminders()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Methods required for the table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellNum:Int = indexPath.row
        
        print(cellNum)
        print(reminders.count)
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "remindercell")! as UITableViewCell
        
        cell.textLabel!.text = reminders[cellNum].description
        cell.detailTextLabel!.numberOfLines = 3
        cell.detailTextLabel!.text = getDetailText(reminders[cellNum])
        
        return cell;
    }
    
    func getDetailText(_ reminder: Reminder) -> String{
        var detailText = ""
        
        // check if user based reminder
        if reminder.forUser != nil{
            if(reminder.forUser! == currentUser!){
                detailText += "Tagged by: \(reminder.byUser)"
            }else{
                detailText += "Tagged user: \(reminder.forUser!)"
            }
        }
        // if not user based it must be landmark based
        else{
            detailText += "\(reminder.getEventType()) landmark: \(reminder.locationName!)"
        }
        
        return detailText
    }
    
    // end table View data source methods
    
    func updateActiveReminders(){
        reminders = Array(activeReminders.values)
        reminders.append(contentsOf: Array(activeForReminders.values))
        homeViewTable.reloadData()
    }
    
    @IBAction func prepareForUnwind(for unwindSegue: UIStoryboardSegue) {
            updateActiveReminders()
    }
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        /*  if (segue.destinationViewController is PlayerDetailController) {
         let child:PlayerDetailController = segue.destinationViewController as! PlayerDetailController
         //let selectedRow = self.tableViewOutlet.indexPathForSelectedRow
         //let defaults = NSUserDefaults.standardUserDefaults()
         //let arrayOfPlayer = defaults.stringArrayForKey("PlayerName")
         child.playerName = text
         print("prepare for seque called")
         }*/
        
        if (segue.identifier == "showDetail") {
            
            // initialize new view controller and cast it as your view controller
            let child:ReminderDetailViewController = segue.destination as! ReminderDetailViewController
            // your new view controller should have property that will store passed value
            //child.playersName = name
        }
        
    }
    
    
    // two optional UITableViewDelegate functions
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        defaults.set(indexPath[1], forKey: "index")
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
//        name = cell!.textLabel!.text!
        performSegue(withIdentifier: "showDetail", sender: self)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
