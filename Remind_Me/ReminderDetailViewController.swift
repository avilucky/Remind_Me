//
//  ReminderDetailViewController.swift
//  Remind_Me
//
//  Created by macbook_user on 11/30/16.
//  Copyright © 2016 Ajinkya Kulkarni. All rights reserved.
//

import UIKit
import Firebase

class ReminderDetailViewController: UIViewController {

    
    @IBOutlet weak var reminderDescription: UILabel!
    
    @IBOutlet weak var reminderDate: UILabel!
    
    @IBOutlet weak var reminderUser: UILabel!
    
    @IBOutlet weak var notifySwitch: UISwitch!
    
    @IBAction func switchClicked() {
        if notifySwitch.isOn
        {
            reminders[index].notified = false;
            print(true)
        }
        else
        {
            reminders[index].notified = true;
            print(false)
        }
    
    }
    var ref: FIRDatabaseReference!

    @IBOutlet weak var dismissButtonOutlet: UIButton!
    
    @IBOutlet weak var reminderStatus: UILabel!
    
    @IBOutlet weak var notifyLabel: UILabel!
    
    
    @IBAction func dismissButtonClicked() {
        
        
        let alertController = UIAlertController(title: "Dismiss", message: "Dimiss Reminder\nTConfirm", preferredStyle: .alert)
        
        let actionYes = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction) in
            print("You've pressed the Yes button");
            
            
            
            // dismiss the reminder
            
            let dismissedDate = Date()
            let reminderByIndex = self.reminders[self.index].fireBaseByIndex
            
            // move this reminder from activeReminders to dismissed reminders
            dismissedReminders[reminderByIndex!] = activeReminders[reminderByIndex!]
            activeReminders.removeValue(forKey: reminderByIndex!)
            
            let reminder = dismissedReminders[reminderByIndex!]
            reminder!.date = dismissedDate
            reminder!.reminderStatus = .dismissed
            
            if(reminder!.fireBaseForIndex != nil){
                self.ref.child("forReminders").child(reminder!.forUser).child(reminder!.fireBaseForIndex).child("reminderStatus").setValue(reminder!.getReminderStatus())
                self.ref.child("forReminders").child(reminder!.forUser).child(reminder!.fireBaseForIndex).child("date").setValue(reminder!.date.description)
            }
            self.ref.child("reminders").child(reminder!.byUser).child(reminder!.fireBaseByIndex).child("reminderStatus").setValue(reminder!.getReminderStatus())
            self.ref.child("reminders").child(reminder!.byUser).child(reminder!.fireBaseByIndex).child("date").setValue(reminder!.date.description)
            self.dismissButtonOutlet.isEnabled = false
            self.reminderStatus.text = "dismissed"
            
        }
        
        let actionNo = UIAlertAction(title: "No", style: .default) { (action:UIAlertAction) in
            print("You've pressed No button");
        }
        
        alertController.addAction(actionYes)
        alertController.addAction(actionNo)
        self.present(alertController, animated: true, completion:nil)
        
        
    }
    

    
    
    
    var index: Int = 0
    var reminders: [Reminder] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()

        reminderUser.numberOfLines = 0
        reminderDescription.numberOfLines = 0
        reminderDate.numberOfLines = 0
        
        reminders = Array(activeReminders.values)
        reminders.append(contentsOf: Array(activeForReminders.values))

        
        
        if let indexNum:Int = defaults.integer(forKey: "index")
        {
            index = indexNum
        }
        print("~~~~~~~")

        reminderDescription.text = reminders[index].description
        
        reminderStatus.text = reminders[index].getReminderStatus()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateString = dateFormatter.string(from: reminders[index].date)
        reminderDate.text = dateString
        
        
        if reminders[index].forUser != nil{
            if(reminders[index].forUser! == currentUser!){
                reminderUser.text = reminders[index].forUser
            }else{
                reminderUser.text = reminders[index].forUser
            }
        }
            // if not user based it must be landmark based
        else{
            reminderUser.text = reminders[index].locationName
        }
        
        notifySwitch.isOn = !reminders[index].notified
        
        if currentUser != reminders[index].byUser
        {
            dismissButtonOutlet.isHidden = true
            notifyLabel.isHidden = true
            notifySwitch.isHidden = true
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

}
