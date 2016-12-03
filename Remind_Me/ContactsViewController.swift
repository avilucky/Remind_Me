//
//  ContactsViewController.swift
//  Remind_Me
//
//  Created by macbook_user on 11/27/16.
//  Copyright © 2016 Ajinkya Kulkarni. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import Firebase

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var contactsTableView: UITableView!
    
    var deviceContacts: [String] = []
    var firebaseContacts: [Any] = []
    var commonUsernames: [String] = []
    var commonContactsWithNames: [String: String] = [String: String]()
    var commonContactsWithUsernames: [String: String] = [String: String]()
    var ref: FIRDatabaseReference!
    var contactsPhone: [CNContact] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()

        contactsTableView.delegate = self
        contactsTableView.dataSource = self
       
        populateDeviceContacts()
        for cn in contactsPhone
        {
            if cn.phoneNumbers.first != nil{
            let phone: CNPhoneNumber = (cn.phoneNumbers.first?.value)!
                if phone.value(forKey: "digits") != nil {
            deviceContacts.append(phone.value(forKey: "digits") as! String)
            
            let first: String = cn.givenName
            let last: String = cn.familyName
            let full:String = first + last
        commonContactsWithUsernames[phone.value(forKey: "digits") as! String] = full
                }}}
        
        for cn in contactsOnFireBase
        {
            if deviceContacts.contains(where: {$0 == cn.value})
            {
                commonContactsWithNames[cn.key] = commonContactsWithUsernames[cn.value]
                commonUsernames.append(cn.key)
            }
            
        }
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
