//
//  UserBasedRemindersViewController.swift
//  Remind_Me
//
//  Created by Ajinkya Kulkarni on 11/5/16.
//  Copyright © 2016 Avinash Talreja. All rights reserved.
//

import UIKit
import Firebase
import Contacts
import ContactsUI


class UserBasedRemindersViewController: UIViewController, UITextViewDelegate {
    
    var countries:[String] = []
    var ref: FIRDatabaseReference!
    var deviceContacts: [String] = []
    var firebaseContacts: [Any] = []
    var isFirstLoad: Bool = true
    var usernameArr:[String] = []
    var commonUsernames:[String] = []
    var contactsPhone: [CNContact] = []
    
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var notificationDesc: UITextView!
    var placeholderLabel : UILabel!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var tagUsers: UITextField!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var selectedDistance: UILabel!
    
    var registerSuccess:Bool = true
    var errorMessage:String?
    
    override func viewDidLoad() {
        ref = FIRDatabase.database().reference()
        
        super.viewDidLoad()
        let color = UIColor(red: 43.0/255.0, green: 66.0/255.0, blue: 134.0/255.0, alpha: 1.0)

        UITabBar.appearance().backgroundColor = color
        
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
        
        populateDeviceContacts()
        for cn in contactsPhone {
            if cn.phoneNumbers.first != nil{
                let phone: CNPhoneNumber = (cn.phoneNumbers.first?.value)!
                if phone.value(forKey: "digits") != nil {
                    deviceContacts.append(phone.value(forKey: "digits") as! String)
        }}}
        
        
        for cn in contactsOnFireBase
        {
            if deviceContacts.contains(where: {$0 == cn.value})
            {
                commonUsernames.append(cn.key)
            }
            
        }
    }
    
    
  
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.isFirstLoad {
            self.isFirstLoad = false
            Autocomplete.setupAutocompleteForViewcontroller(self)
        }
    }


    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func slideChangeEvent(_ sender: UISlider) {
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
        // TODO validation needs to be applied
        // and accordingly should override shouldPerformSegue
        validateUserBasedReminderEntry()
        
        if !registerSuccess {
            let alertController = UIAlertController(title: "User based reminder validation error", message: errorMessage!, preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Return", style:UIAlertActionStyle.default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        let distance = Int(distanceSlider.value)
        //test distance slider value
        print("\(distanceSlider.value) to \(distance)")
        let reminder: Reminder = Reminder(forUser: username.text!, byUser: currentUser!, date: date.date, description: notificationDesc.text!, distance: distance, latitude: 0.0, longitude: 0.0)
        
        let msg = ref.child("reminders").child(currentUser!).childByAutoId()
        let forMsg = ref.child("forReminders").child(reminder.forUser).childByAutoId()
        
        reminder.fireBaseByIndex = msg.key
        reminder.fireBaseForIndex = forMsg.key
        
        let value = ["forUser": reminder.forUser!, "fireBaseByIndex": reminder.fireBaseByIndex!, "fireBaseForIndex": reminder.fireBaseForIndex!, "byUser": reminder.byUser, "date": reminder.date.description, "description": reminder.description, "distance": distance.description, "latitude": "0.0", "longitude": "0.0", "reminderStatus": reminder.getReminderStatus()]
        
        msg.setValue(value)
        forMsg.setValue(value)
        
        if reminder.reminderStatus == .active{
            activeReminders[msg.key] = reminder
        }else{
            upcomingReminders[msg.key] = reminder
            let delegate = UIApplication.shared.delegate as? AppDelegate
            if delegate != nil{
                Timer.scheduledTimer(timeInterval: reminder.date.timeIntervalSinceNow, target: delegate!, selector: #selector(delegate!.updateReminders), userInfo: reminder, repeats: false)
            }
        }
        
        print(activeReminders)
        print(upcomingReminders)
        
        self.performSegue(withIdentifier: "unwindToHomeFromUser", sender: nil)
    }
    
    func validateUserBasedReminderEntry() {
        let description: String = notificationDesc.text!
        let usernameText: String = username.text!
        errorMessage = nil
        
        if usernameText == "" && description == ""{
            errorMessage = "Tagged user and notification description can not be empty"
        }else if usernameText == ""{
            errorMessage = "Tagged user can not be empty"
        }else if description == ""{
            errorMessage = "Notification description can not be empty"
        }
        
        // print(commonUsernames)
        // we can also add validation of username is associated with contact that is no such
        // user exists
        if(!commonUsernames.contains(usernameText))
        {
            errorMessage = "Tagged user not found"
        }
        
        if errorMessage != nil{
            registerSuccess = false
        }else{
            registerSuccess = true
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
    
    func populateDeviceContacts(){
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        var allContainers: [CNContainer] = []
        do
        {
            allContainers = try contactStore.containers(matching: nil)
        }
        catch
        {
            print("Error fetching containers")
        }
        for container in allContainers
        {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            do
            {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                contactsPhone.append(contentsOf: containerResults)
            }
            catch
            {
                print("Error fetching result for container")
            }
        }
    }
    
//    func autoCompleteTextField() -> UITextField{
//    return tagUsers
//    }
//    func autoCompleteThreshold(textField: UITextField) -> Int{
//    return 2
//    }
//    func autoCompleteItemsForSearchTerm(term: String) -> [AutocompletableOption]{
//        let aj:AutocompletableOption = "Ajinkya" as! AutocompletableOption
//        let ak:AutocompletableOption = "Aniket" as! AutocompletableOption
//    return [aj,ak]}
//    func autoCompleteHeight() -> CGFloat{
//    return 2.0}
//    func didSelectItem(item: AutocompletableOption) -> Void{}
}

extension UserBasedRemindersViewController: AutocompleteDelegate {
    func autoCompleteTextField() -> UITextField {
        return self.tagUsers
    }
    func autoCompleteThreshold(_ textField: UITextField) -> Int {
        return 1
    }
    
    func autoCompleteItemsForSearchTerm(_ term: String) -> [AutocompletableOption] {
        let filteredCountries = self.commonUsernames.filter { (usernames) -> Bool in
            return usernames.lowercased().contains(term.lowercased())
        }
        
        let commonUser: [AutocompletableOption] = filteredCountries.map { ( country) -> AutocompleteCellData in
            var country = country
            country.replaceSubrange(country.startIndex...country.startIndex, with: String(country.characters[country.startIndex]).lowercased())
            return AutocompleteCellData(text: country)
            }.map( { $0 as AutocompletableOption })
        
        return commonUser
    }
    
    func autoCompleteHeight() -> CGFloat {
        return self.view.frame.height / 3.0
    }
    
    
    func didSelectItem(_ item: AutocompletableOption) {
       print(item.text)
    }
}

