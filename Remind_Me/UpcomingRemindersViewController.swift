//
//  UpcomingRemindersViewController.swift
//  Remind_Me
//
//  Created by Avinash Talreja on 11/23/16.
//  Copyright © 2016 Avinash Talreja. All rights reserved.
//

import UIKit

class UpcomingRemindersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var upcomingViewTable: UITableView!
    var reminders: [Reminder] = []
    var selectedReminder: Reminder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("upcoming view load")
        upcomingViewTable.dataSource = self
        upcomingViewTable.delegate = self

        updateReminders()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.isViewLoaded{
            //print("update reminders called")
            updateReminders()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // Methods required for the table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellNum:Int = indexPath.row
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "upcomingremindercell")! as UITableViewCell
        
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
            detailText += "Landmark: \(reminder.locationName!)"
        }
        detailText += "\n"
        
        detailText += "Event begins: \(globalDateFormatter.string(from: reminder.date))"
        print(detailText)
        return detailText
    }
    
    func updateReminders(){
        reminders = Array(upcomingReminders.values)
        reminders.append(contentsOf: Array(upcomingForReminders.values))
        upcomingViewTable.reloadData()
    }
    
    @IBAction func prepareForUnwindUp(for unwindSegue: UIStoryboardSegue) {
        updateReminders()
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
        
        if (segue.identifier == "showUpcomingDetail") {
            
            // initialize new view controller and cast it as your view controller
            let child:UpcomingReminderDetailViewController = segue.destination as! UpcomingReminderDetailViewController
            // your new view controller should have property that will store passed value
            child.reminder = selectedReminder
        }
    }
    
    
    // two optional UITableViewDelegate functions
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedReminder = reminders[indexPath.row]
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select user \(indexPath.row)")
    }


}
