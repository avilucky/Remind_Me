//
//  UpdateViewController.swift
//  Remind_Me
//
//  Created by macbook_user on 11/26/16.
//  Copyright © 2016 Avinash Talreja. All rights reserved.
//

import UIKit
import Firebase

class UpdateViewController: UIViewController {

    var errorMessage: String?
    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBAction func updateButtonPressed() {
        if validateUserEntry(){
            ref.child("users").child(currentUser!).setValue(["phone": phoneNumberTextField.text!])
            
            let alertController = UIAlertController(title: "Edit Profile Success", message: "Phone Number updated successfully", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Return", style:UIAlertActionStyle.default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        // Do any additional setup after loading the view.
        
        usernameLabel.text = currentUser!
        phoneNumberTextField.text = contactsOnFireBase[currentUser!]!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func validateUserEntry() -> Bool{
        let phoneNumber: String = phoneNumberTextField.text!
        errorMessage = nil
        
        if phoneNumber == ""{
            errorMessage = "Phone number can not be empty"
        }else if phoneNumber.hasPrefix("0") || phoneNumber.characters.count != 10{
            errorMessage = "Phone number has to be of 10 digits and can not start with a 0"
        }else if(contactsOnFireBase[currentUser!] != phoneNumber && Array(contactsOnFireBase.values).contains(phoneNumber)){
            errorMessage = "Phone number already registered"
        }
        
        if errorMessage != nil{
            let alertController = UIAlertController(title: "Edit Profile validation error", message: errorMessage!, preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Return", style:UIAlertActionStyle.default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
            return false
        }
        
        return true
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
