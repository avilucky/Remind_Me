//
//  LandmarkBasedRemindersViewController.swift
//  Remind_Me
//
//  Created by Avinash Talreja on 11/5/16.
//  Copyright © 2016 Avinash Talreja. All rights reserved.
//

import UIKit
import Firebase

class LandmarkBasedRemindersViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {

    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var notificationDesc: UITextView!
    var placeholderLabel : UILabel!
    @IBOutlet weak var eventTypePicker: UIPickerView!
    
    let pickerData = ["nearby", "leaving", "reached"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        
        eventTypePicker.dataSource = self
        eventTypePicker.delegate = self
        
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
    
    // The number of columns of data
    func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
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
        // TODO validation needs to be applied, change hardcoded values locationName, latitude and longitude
        // and accordingly should override shouldPerformSegue
        
        let eveType: EventType = EventType.getEventTypeEnum(eventType: pickerData[eventTypePicker.selectedRow(inComponent: 0)])
        
        let reminder: Reminder = Reminder(byUser: currentUser!, date: date.date, description: notificationDesc.text!, locationName: "test", latitude: 4.63535, longitude: 53.234242, eventType: eveType)
        
        let msg = ref.child("reminders").child(currentUser!).childByAutoId()
        
        reminder.fireBaseIndex = msg.key
        
        let value = ["byUser": reminder.byUser, "date": reminder.date.description, "description": reminder.description, "locationName": reminder.locationName!, "latitude": reminder.latitude!.description, "longitude": reminder.longitude!.description, "eventType": reminder.getEventType(), "reminderStatus": reminder.getReminderStatus()]
        
        msg.setValue(value)
        
        if reminder.reminderStatus == .active{
            activeReminders.append(reminder)
        }else{
            upcomingReminders.append(reminder)
        }
        
        print(activeReminders)
        print(upcomingReminders)
        
        self.performSegue(withIdentifier: "unwindToHomeFromLandMark", sender: nil)
    }
}
