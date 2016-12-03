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

    
    @IBOutlet weak var reminderDescription: UILabel!
    
    @IBOutlet weak var reminderDate: UILabel!
    
    @IBOutlet weak var reminderUser: UILabel!
    
    var ref: FIRDatabaseReference!

    @IBOutlet weak var dismissButtonOutlet: UIButton!
    
    @IBOutlet weak var reminderStatus: UILabel!
    
    
    

    
    
    
    var index: Int = 0
    var reminders: [Reminder] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()

        reminderUser.numberOfLines = 0
        reminderDescription.numberOfLines = 0
        reminderDate.numberOfLines = 0
        
        reminders = Array(dismissedReminders.values)
        reminders.append(contentsOf: Array(dismissedReminders.values))

        
        
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
