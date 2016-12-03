//
//  DismissedRemindersViewController.swift
//  Remind_Me
//
//  Created by Avinash Talreja on 11/23/16.
//  Copyright © 2016 Avinash Talreja. All rights reserved.
//

import UIKit

class DismissedRemindersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var dismissedViewTable: UITableView!
    var reminders: [Reminder] = []
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "EEE, MMM d, yyyy - h:mm a"
        dateFormatter.timeZone = NSTimeZone.local
        
        dismissedViewTable.dataSource = self
        dismissedViewTable.delegate = self

        updateReminders()
        // Do any additional setup after loading the view.
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
        
        print(cellNum)
        print(reminders.count)
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "dismissedremindercell")! as UITableViewCell
        
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
        
        detailText += "Dismissed date: \(dateFormatter.string(from: reminder.date))"
        print(detailText)
        return detailText
    }
    
    func updateReminders(){
        reminders = Array(dismissedReminders.values)
        reminders.append(contentsOf: Array(dismissedForReminders.values))
        dismissedViewTable.reloadData()
    }
    @IBAction func prepareForUnwindDis(for unwindSegue: UIStoryboardSegue) {
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
        
        if (segue.identifier == "showDismissedDetail") {
            
            // initialize new view controller and cast it as your view controller
            let child:DismissedReminderDetailViewController = segue.destination as! DismissedReminderDetailViewController
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
        
        _ = tableView.cellForRow(at: indexPath)
        //        name = cell!.textLabel!.text!
        performSegue(withIdentifier: "showDismissedDetail", sender: self)
        
    }

}
