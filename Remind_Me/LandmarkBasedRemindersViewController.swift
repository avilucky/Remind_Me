//
//  LandmarkBasedRemindersViewController.swift
//  Remind_Me
//
//  Created by Avinash Talreja on 11/5/16.
//  Copyright © 2016 Avinash Talreja. All rights reserved.
//

import UIKit
import Firebase

class LandmarkBasedRemindersViewController: UIViewController, UITextViewDelegate {

    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var notificationDesc: UITextView!
    var placeholderLabel : UILabel!
    @IBOutlet weak var locationAddress: UITextField!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var selectedDistance: UILabel!
    
    var lat: Double = 0
    var lon: Double = 0
    var registerSuccess:Bool = true
    var errorMessage:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        
        // register keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
      
        // disable the past date in date picker
        self.date.minimumDate = Date()
        self.date.tintColor = UIColor.white
        self.date.backgroundColor = UIColor.white
    
        // place a placeholder on notification description
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
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let distance = Int(distanceSlider.value)
        selectedDistance.text = distance.description + " m."
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
        validateLandmarkBasedReminderEntry()
            
        if !registerSuccess {
            let alertController = UIAlertController(title: "Landmark based reminder validation error", message: errorMessage!, preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Return", style:UIAlertActionStyle.default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        let distance = Int(distanceSlider.value)
        //test distance slider value
        print("\(distanceSlider.value) to \(distance)")
        
        let reminder: Reminder = Reminder(byUser: currentUser!, date: date.date, description: notificationDesc.text!, locationName: locationAddress.text!, distance: distance,latitude: lat, longitude: lon)
        
        let msg = ref.child("reminders").child(currentUser!).childByAutoId()
        
        reminder.fireBaseByIndex = msg.key
        
        let value = ["byUser": reminder.byUser, "fireBaseByIndex": reminder.fireBaseByIndex!, "date": reminder.date.description, "description": reminder.description, "locationName": reminder.locationName!, "latitude": reminder.latitude!.description, "longitude": reminder.longitude!.description, "distance": distance.description, "reminderStatus": reminder.getReminderStatus()]
        
        msg.setValue(value)
        
        if reminder.reminderStatus == .active{
            activeReminders[msg.key] = reminder
        }else{
            upcomingReminders[msg.key] = reminder
            let delegate = UIApplication.shared.delegate as? AppDelegate
            if delegate != nil{
                print("timer scheduled after \(reminder.date.timeIntervalSinceNow)")
                Timer.scheduledTimer(timeInterval: reminder.date.timeIntervalSinceNow, target: delegate!, selector: #selector(delegate!.updateReminders), userInfo: reminder, repeats: false)
            }
        }
        
//        print(activeReminders)
//        print(upcomingReminders)
        
        self.performSegue(withIdentifier: "unwindToHomeFromLandMark", sender: nil)
        
    }
    
    func validateLandmarkBasedReminderEntry() {
        let description: String = notificationDesc.text!
        let locationName: String = locationAddress.text!
        errorMessage = nil
        
        if locationName == "" && description == ""{
            errorMessage = "Location and notification description can not be empty"
        }else if locationName == ""{
            errorMessage = "Location can not be empty"
        }else if description == ""{
            errorMessage = "Notification description can not be empty"
        }
        
        // we can also add validation of username is associated with contact that is no such
        // user exists
        
        if errorMessage != nil{
            registerSuccess = false
        }else{
            registerSuccess = true
        }
    }

    @IBAction func unwindToLocation(segue: UIStoryboardSegue) {
        let defaults = UserDefaults.standard
        if let add = defaults.string(forKey: "locationAddress")
        {
            locationAddress.text! = add
        }
        
        if let latitude: Double = defaults.double(forKey: "latitude")
        {
            lat = latitude
        }
        
        if let longitude: Double = defaults.double(forKey: "longitude")
        {
            lon = longitude
        }

    }
    
    // keyboard notifications functions
    func keyboardWillShow(notification: NSNotification) {
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        if (keyboardSize != nil) {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= 165
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        if (keyboardSize != nil) {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += 165
            }
        }
    }
}
