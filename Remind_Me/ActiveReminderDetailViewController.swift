//
//  ReminderDetailViewController.swift
//  Remind_Me
//
//  Created by macbook_user on 11/30/16.
//  Copyright © 2016 Ajinkya Kulkarni. All rights reserved.
//

import UIKit
import Firebase

class ActiveReminderDetailViewController: UIViewController {

    var reminder: Reminder!
    
    @IBOutlet weak var reminderDescription: UITextView!
    
    @IBOutlet weak var reminderDate: UILabel!
    
    @IBOutlet weak var reminderUser: UILabel!
    
    @IBOutlet weak var notifySwitch: UISwitch!
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var dismissButtonOutlet: UIButton!
    
    @IBOutlet weak var reminderStatus: UILabel!
    
    @IBOutlet weak var notifyLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBAction func switchClicked() {
        if notifySwitch.isOn
        {
            reminder.notified = false;
            print(true)
        }
        else
        {
            reminder.notified = true;
            print(false)
        }
        
        self.performSegue(withIdentifier: "unwindToActiveFromView", sender: nil)
    }
    
    @IBAction func dismissButtonClicked() {
        
        let reminderByIndex = self.reminder.fireBaseByIndex
        
        if(activeReminders[reminderByIndex!] == nil){
            let alertController = UIAlertController(title: "Dismiss Error", message: "The detail view is of a stale reminder. You will be redirected to table view and you can perform appropriate action from there", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Return", style:UIAlertActionStyle.default) {
                (UIAlertAction) in
                
                self.performSegue(withIdentifier: "unwindToActiveFromView", sender: nil)
            })
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        let alertController = UIAlertController(title: "Dismiss", message: "Dimiss Reminder\nConfirm", preferredStyle: .alert)
        
        let actionYes = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction) in
            print("You've pressed the Yes button");
            
            
            
            // dismiss the reminder
            
            let dismissedDate = Date()
            
            // move this reminder from activeReminders to dismissed reminders
            dismissedReminders[reminderByIndex!] = activeReminders[reminderByIndex!]
            activeReminders.removeValue(forKey: reminderByIndex!)
            
            let reminder = dismissedReminders[reminderByIndex!]
            reminder!.date = dismissedDate
            reminder!.reminderStatus = .dismissed
            
            if(reminder!.fireBaseForIndex != nil){
                self.ref.child("forReminders").child(reminder!.forUser).child(reminder!.fireBaseForIndex).updateChildValues(["date": reminder!.date.description, "reminderStatus": reminder!.getReminderStatus()])
            }
            self.ref.child("reminders").child(reminder!.byUser).child(reminder!.fireBaseByIndex).updateChildValues(["date": reminder!.date.description, "reminderStatus": reminder!.getReminderStatus()])
            
            self.dismissButtonOutlet.isEnabled = false
            self.reminderStatus.text = "dismissed"
            
            self.performSegue(withIdentifier: "unwindToActiveFromView", sender: nil)
        }
        
        let actionNo = UIAlertAction(title: "No", style: .default) { (action:UIAlertAction) in
            print("You've pressed No button");
        }
        
        alertController.addAction(actionYes)
        alertController.addAction(actionNo)
        self.present(alertController, animated: true, completion:nil)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        
        reminderUser.numberOfLines = 0
        reminderDate.numberOfLines = 0
        
        reminderDescription.text = reminder.description
        
        reminderStatus.text = reminder.getReminderStatus()
        distanceLabel.text = reminder.distance.description + " m."
        let dateString = globalDateFormatter.string(from: reminder.date)
        reminderDate.text = dateString
        
        
        if reminder.forUser != nil{
            reminderUser.text = reminder.forUser
        }
            // if not user based it must be landmark based
        else{
            reminderUser.text = reminder.locationName
        }
        
        notifySwitch.isOn = !reminder.notified
        
        if currentUser != reminder.byUser
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
