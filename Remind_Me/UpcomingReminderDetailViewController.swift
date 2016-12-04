//
//  ReminderDetailViewController.swift
//  Remind_Me
//
//  Created by macbook_user on 11/30/16.
//  Copyright © 2016 Ajinkya Kulkarni. All rights reserved.
//

import UIKit
import Firebase

class UpcomingReminderDetailViewController: UIViewController {

    var reminder: Reminder!
    
    @IBOutlet weak var reminderDescription: UITextView!
    
    @IBOutlet weak var reminderDate: UILabel!
    
    @IBOutlet weak var reminderUser: UILabel!
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var dismissButtonOutlet: UIButton!
    
    @IBOutlet weak var reminderStatus: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBAction func dismissButtonClicked() {
        
        
        let alertController = UIAlertController(title: "Dismiss", message: "Dimiss Reminder\nConfirm", preferredStyle: .alert)
        
        let actionYes = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction) in
            print("You've pressed the Yes button");
            
            // dismiss the reminder
            
            let dismissedDate = Date()
            let reminderByIndex = self.reminder.fireBaseByIndex
            
            // move this reminder from upcomingReminders to dismissed reminders
            dismissedReminders[reminderByIndex!] = upcomingReminders[reminderByIndex!]
            upcomingReminders.removeValue(forKey: reminderByIndex!)
            
            let reminder = dismissedReminders[reminderByIndex!]
            reminder!.date = dismissedDate
            reminder!.reminderStatus = .dismissed
            
            if(reminder!.fireBaseForIndex != nil){
                
                self.ref.child("forReminders").child(reminder!.forUser).child(reminder!.fireBaseForIndex).child("date").setValue(reminder!.date.description)
                
                self.ref.child("forReminders").child(reminder!.forUser).child(reminder!.fireBaseForIndex).child("reminderStatus").setValue(reminder!.getReminderStatus())
            }
            self.ref.child("reminders").child(reminder!.byUser).child(reminder!.fireBaseByIndex).child("reminderStatus").setValue(reminder!.getReminderStatus())
            self.ref.child("reminders").child(reminder!.byUser).child(reminder!.fireBaseByIndex).child("date").setValue(reminder!.date.description)
            self.dismissButtonOutlet.isEnabled = false
            self.reminderStatus.text = "dismissed"
            
            self.performSegue(withIdentifier: "unwindToUpcomingFromView", sender: nil)
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
        
        if currentUser != reminder.byUser
        {
            dismissButtonOutlet.isHidden = true
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
