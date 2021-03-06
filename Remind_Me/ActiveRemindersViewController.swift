//
//  ActiveRemindersViewController.swift
//  Remind_Me
//
//  Created by Avinash Talreja on 11/23/16.
//  Copyright © 2016 Avinash Talreja. All rights reserved.
//

import UIKit

class ActiveRemindersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var activeViewTable: UITableView!
    var reminders: [Reminder] = []
    var selectedReminder: Reminder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("active view load")
        activeViewTable.dataSource = self
        activeViewTable.delegate = self
        self.activeViewTable.backgroundColor = UIColor.lightGray

        updateReminders()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        //print("active view will appear")
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
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "activeremindercell")! as UITableViewCell
        
        cell.textLabel!.text = reminders[cellNum].description
        cell.detailTextLabel!.numberOfLines = 2
        cell.detailTextLabel!.text = getDetailText(reminders[cellNum])
        
        if(reminders[cellNum].notified){
            cell.backgroundColor = UIColor(red:0.17, green:0.26, blue:0.53, alpha:0.45)
            cell.textLabel?.backgroundColor = UIColor.clear
            cell.detailTextLabel?.backgroundColor = UIColor.clear
            cell.textLabel?.textColor = UIColor.white
            cell.detailTextLabel?.textColor = UIColor.white
        }else{
            cell.backgroundColor = UIColor.white
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
        }
        
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
        
        return detailText
    }
    
    func updateReminders(){
        reminders = Array(activeReminders.values)
        reminders.append(contentsOf: Array(activeForReminders.values))
        activeViewTable.reloadData()
    }
    
    @IBAction func prepareForUnwindAct(for unwindSegue: UIStoryboardSegue) {
        updateReminders()
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "showActiveDetail") {
            
            // initialize new view controller and cast it as your view controller
            let child:ActiveReminderDetailViewController = segue.destination as! ActiveReminderDetailViewController
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
