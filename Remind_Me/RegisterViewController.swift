//
//  RegisterViewController.swift
//  Remind_Me
//
//  Created by Avinash Talreja on 10/29/16.
//  Copyright © 2016 Avinash Talreja. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    var ref: FIRDatabaseReference!
    var registerSuccess:Bool = true
    var errorMessage:String?
    
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var phoneNumberLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        // register keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func registerUser() {
        if validateUserEntry(){
            ref.child("users").child(usernameLabel.text!).setValue(["phone": phoneNumberLabel.text!])
            defaults.set(usernameLabel.text!, forKey: "username")
            currentUser = usernameLabel.text!
            
            let delegate = UIApplication.shared.delegate as? AppDelegate
            if delegate != nil{
                delegate!.changeRootController()
            }
        }
    }
    
    func validateUserEntry() -> Bool{
        let username: String = usernameLabel.text!
        let phoneNumber: String = phoneNumberLabel.text!
        errorMessage = nil
        
        if username == "" && phoneNumber == ""{
            errorMessage = "User name and phone number can not be empty"
        }else if username == ""{
            errorMessage = "User name can not be empty"
        }else if phoneNumber == ""{
            errorMessage = "Phone number can not be empty"
        }else if phoneNumber.hasPrefix("0") || phoneNumber.characters.count != 10{
            errorMessage = "Phone number has to be of 10 digits and can not start with a 0"
        }else if(contactsOnFireBase[username] != nil){
            errorMessage = "User name already taken"
        }else if(Array(contactsOnFireBase.values).contains(phoneNumber)){
            errorMessage = "Phone number already registered"
        }
        
        if errorMessage != nil{
            let alertController = UIAlertController(title: "Register validation error", message: errorMessage!, preferredStyle: UIAlertControllerStyle.alert)
            
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
