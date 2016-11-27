//
//  ContactsViewController.swift
//  Remind_Me
//
//  Created by macbook_user on 11/27/16.
//  Copyright © 2016 Avinash Talreja. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import Firebase

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var contactsTableView: UITableView!
    
    var deviceContacts: [CFNumber] = []
    var firebaseContacts: [Any] = []
    var commonUsernames: [String] = []
    var commonContactsWithNames: [String: String] = [String: String]()
    var commonContactsWithUsernames: [String: CFNumber] = [String: CFNumber]()
    var ref: FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()

        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        
        for cn in contacts {
            let temp: CNPhoneNumber = cn.phoneNumbers[0].value
            deviceContacts.append(temp.value(forKey: "digits")! as! CFNumber)
            let strs:CFNumber = temp.value(forKey: "digits")! as! CFNumber
            
            
        }
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as! NSDictionary
            let temp: [Any] = value.allValues
            var usernameArr:[String] = []
            usernameArr = value.allKeys as! [String]
            var i : Int = 0
            for cn in temp
            {
                let values = cn as! NSDictionary
                self.firebaseContacts.append(values.value(forKey: "phone")!)
                let str:CFNumber = values.value(forKey: "phone")! as! CFNumber
                if self.deviceContacts.contains(where: {$0 == str}) {
                    // it exists, do something
                self.commonContactsWithUsernames[usernameArr[i]] = str
                    
                    
                    
                } else {
                    // item not found
                }
                for cn in self.contacts{
                    
                    let temp: CNPhoneNumber = cn.phoneNumbers[0].value
                    let strs:CFNumber = temp.value(forKey: "digits")! as! CFNumber
                    let name = cn.givenName + cn.familyName
                    if(strs == str)
                    {
                        self.commonContactsWithNames[usernameArr[i]] = name
                        self.commonUsernames.append(usernameArr[i])
                    }
                    

                }
                i += 1
            }
            print(self.commonContactsWithUsernames)
            print(self.commonContactsWithNames)
            print(self.commonUsernames)
            
            self.updateContactsOnView()
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // Do any additional setup after loading the view.
    
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateContactsOnView(){
        commonUsernames.sort()
        contactsTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commonUsernames.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellNum:Int = indexPath.row
        
        print(cellNum)
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "contactsCell")! as UITableViewCell
        
        cell.textLabel!.text = commonUsernames[cellNum]
        
        cell.detailTextLabel!.text = commonContactsWithNames[commonUsernames[cellNum]]
        
        return cell;
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
