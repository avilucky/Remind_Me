//
//  ReminderDetailViewController.swift
//  Remind_Me
//
//  Created by macbook_user on 11/30/16.
//  Copyright © 2016 Ajinkya Kulkarni. All rights reserved.
//

import UIKit
import Firebase

class DismissedReminderDetailViewController: UIViewController {

    var reminder: Reminder!
    
    @IBOutlet weak var reminderDescription: UITextView!
    
    @IBOutlet weak var reminderDate: UILabel!
    
    @IBOutlet weak var reminderUser: UILabel!
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var reminderStatus: UILabel!

    @IBOutlet weak var distanceLabel: UILabel!
    
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
