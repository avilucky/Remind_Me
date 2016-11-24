//
//  UserBasedRemindersViewController.swift
//  Remind_Me
//
//  Created by Avinash Talreja on 11/5/16.
//  Copyright © 2016 Avinash Talreja. All rights reserved.
//

import UIKit
import Firebase
import Contacts
import ContactsUI


class UserBasedRemindersViewController: UIViewController, UITextViewDelegate {
    
    var countries:[String] = []
    var ref: FIRDatabaseReference!
    var deviceContacts: [CFNumber] = []
    var firebaseContacts: [Any] = []
    var isFirstLoad: Bool = true
    
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var notificationDesc: UITextView!
    var placeholderLabel : UILabel!
    @IBOutlet weak var username: UITextField!
    
    
    @IBOutlet weak var tagUsers: UITextField!
    
    
    
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
        for cn in contacts {
            let temp: CNPhoneNumber = cn.phoneNumbers[0].value
            deviceContacts.append(temp.value(forKey: "digits")! as! CFNumber)
            let strs:CFNumber = temp.value(forKey: "digits")! as! CFNumber
            print(strs)
            
        }
        //
        print("~~~~~~~~~~~")
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as! NSDictionary
            let temp: [Any] = value.allValues
            var usernameArr:[String] = []
            usernameArr = value.allKeys as! [String]
            print(usernameArr)
            var i : Int = 0
            for cn in temp
            {
                let values = cn as! NSDictionary
                self.firebaseContacts.append(values.value(forKey: "phone")!)
                let str:CFNumber = values.value(forKey: "phone")! as! CFNumber
                print(str)
                
                
                
                
                if self.deviceContacts.contains(where: {$0 == str}) {
                    // it exists, do something
                    print(true)
                    print(usernameArr[i])
                    self.countries.append(usernameArr[i])

                    
                } else {
                    // item not found
                    print(false)
                }
                i += 1
            }
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    
    lazy var contacts: [CNContact] = {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        return results
    }()
    
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
        
        let reminder: Reminder = Reminder(forUser: username.text!, byUser: currentUser!, date: date.date, description: notificationDesc.text!)
        
        let forReminder: Reminder = Reminder(forUser: username.text!, byUser: currentUser!, date: date.date, description: notificationDesc.text!)
        
        let msg = ref.child("reminders").child(currentUser!).childByAutoId()
        let forMsg = ref.child("forReminders").child(reminder.forUser).childByAutoId()
        
        reminder.fireBaseIndex = msg.key
        forReminder.fireBaseIndex = forMsg.key
        
        let value = ["forUser": reminder.forUser!, "byUser": reminder.byUser, "date": reminder.date.description, "description": reminder.description, "reminderStatus": reminder.getReminderStatus()]
        
        msg.setValue(value)
        forMsg.setValue(value)
        
        if reminder.reminderStatus == .active{
            activeReminders.append(reminder)
        }else{
            upcomingReminders.append(reminder)
        }
        
        print(activeReminders)
        print(upcomingReminders)
        
        self.performSegue(withIdentifier: "unwindToHomeFromUser", sender: nil)
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
        let filteredCountries = self.countries.filter { (country) -> Bool in
            return country.lowercased().contains(term.lowercased())
        }
        
        let countriesAndFlags: [AutocompletableOption] = filteredCountries.map { ( country) -> AutocompleteCellData in
            var country = country
            country.replaceSubrange(country.startIndex...country.startIndex, with: String(country.characters[country.startIndex]).capitalized)
            return AutocompleteCellData(text: country)
            }.map( { $0 as AutocompletableOption })
        
        return countriesAndFlags
    }
    
    func autoCompleteHeight() -> CGFloat {
        return self.view.frame.height / 3.0
    }
    
    
    func didSelectItem(_ item: AutocompletableOption) {
       print(item.text)
    }
}

