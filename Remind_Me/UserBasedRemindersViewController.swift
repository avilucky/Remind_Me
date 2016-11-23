//
//  UserBasedRemindersViewController.swift
//  Remind_Me
//
//  Created by Avinash Talreja on 11/5/16.
//  Copyright © 2016 Avinash Talreja. All rights reserved.
//

import UIKit
import Firebase

class UserBasedRemindersViewController: UIViewController, UITextViewDelegate {

    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var notificationDesc: UITextView!
    var placeholderLabel : UILabel!
    @IBOutlet weak var username: UITextField!
    
    override func viewDidLoad() {
        ref = FIRDatabase.database().reference()
        
        super.viewDidLoad()

        notificationDesc.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Notification description"
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (notificationDesc.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        notificationDesc.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 80, y: (notificationDesc.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabel.isHidden = !notificationDesc.text.isEmpty
        // Do any additional setup after loading the view.
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
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

    @IBAction func saveReminder() {
        // TODO validation needs to be applied
        // and accordingly should override shouldPerformSegue
        
        let reminder: Reminder = Reminder(forUser: username.text!, byUser: currentUser!, date: date.date, description: notificationDesc.text!, latitude: 0.0, longitude: 0.0)
        
        let msg = ref.child("reminders").child(currentUser!).childByAutoId()
        let forMsg = ref.child("forReminders").child(reminder.forUser).childByAutoId()
        
        reminder.fireBaseByIndex = msg.key
        reminder.fireBaseForIndex = forMsg.key
        
        let value = ["forUser": reminder.forUser!, "fireBaseByIndex": reminder.fireBaseByIndex!, "fireBaseForIndex": reminder.fireBaseForIndex!, "byUser": reminder.byUser, "date": reminder.date.description, "description": reminder.description, "latitude": "0.0", "longitude": "0.0", "reminderStatus": reminder.getReminderStatus()]
        
        msg.setValue(value)
        forMsg.setValue(value)
        
        if reminder.reminderStatus == .active{
            activeReminders[msg.key] = reminder
        }else{
            upcomingReminders[msg.key] = reminder
        }
        
        print(activeReminders)
        print(upcomingReminders)
        
        self.performSegue(withIdentifier: "unwindToHomeFromUser", sender: nil)
    }
    
}
