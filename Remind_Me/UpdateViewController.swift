//
//  UpdateViewController.swift
//  Remind_Me
//
//  Created by macbook_user on 11/26/16.
//  Copyright © 2016 Avinash Talreja. All rights reserved.
//

import UIKit

class UpdateViewController: UIViewController {


    @IBAction func updateButtonPressed(_ sender: Any) {
        let selectedDate = Date()
        print("Selected date: \(selectedDate)")
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let reminder = Array(activeReminders.values).first!
        
        delegate?.scheduleNotification(at: selectedDate, reminder: reminder)
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        delegate?.nearBy(lat: 41.658571, lon: -91.551124, reminder: reminder)
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
