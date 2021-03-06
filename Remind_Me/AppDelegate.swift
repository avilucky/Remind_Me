//
//  AppDelegate.swift
//  Remind_Me
//
//  Created by Avinash Talreja on 10/24/16.
//  Copyright © 2016 Avinash Talreja. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import GoogleMaps
import GooglePlaces
import UserNotifications
import CoreLocation
import IQKeyboardManagerSwift
import Contacts
import ContactsUI


var activeReminders: [String: Reminder] = [String: Reminder]()
var activeForReminders: [String: Reminder] = [String: Reminder]()
var dismissedReminders: [String: Reminder] = [String: Reminder]()
var dismissedForReminders: [String: Reminder] = [String: Reminder]()
var upcomingReminders: [String: Reminder] = [String: Reminder]()
var upcomingForReminders: [String: Reminder] = [String: Reminder]()

var appInBackground: Bool = false


let defaults = UserDefaults.standard
var currentUser: String?

var myLat: Double = 0.0
var myLon: Double = 0.0
let globalDateFormatter = DateFormatter()
var contactsOnFireBase: [String:String] = [String:String]()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var ref: FIRDatabaseReference!
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // set format of the date to be used across the application
        globalDateFormatter.dateFormat = "EEE, MMM d, yyyy - h:mm a"
        globalDateFormatter.timeZone = NSTimeZone.local
        
        // enable IQKeyboardManager
        IQKeyboardManager.sharedManager().enable = true
        
            
        // start updating locations
        locationManager.startUpdatingLocation()
        
        // Override point for customization after application launch.
        FIRApp.configure()
        
        ref = FIRDatabase.database().reference()
        
        // enable key sharing from project settings if this doesn't print anything
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value!)
        })
        
        // for testing purpose to clear defaults and see registerview controller UI
        // defaults.removeObject(forKey: "username")
        
        currentUser = defaults.object(forKey: "username") as? String
        // we check for any username associated with the phone
        let username:String? = currentUser
        
        
        ref.child("users").observe(.value, with: { (snapshot) in
            if snapshot.childrenCount > 0{
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot{
                    let phoneNumber = rest.childSnapshot(forPath: "phone").value as! String
                    if contactsOnFireBase[rest.key] != nil || contactsOnFireBase[rest.key] != phoneNumber{
                        contactsOnFireBase[rest.key] = phoneNumber
                    }
                }
            }
        })
        
        
        if username != nil{
            print("User: \(username)")
            // if yes that is phone has already registered for the app, then look if the
            // details of the users exist on firebase
            ref.child("users").child(username!).observeSingleEvent(of: .value, with: { (snapshot) in

                if snapshot.childrenCount > 0{
                    
                    self.changeRootController()
                    
                    self.updateRemindersForUser()
                }
            })
        }
        GMSServices.provideAPIKey("AIzaSyDQxXl3_hh1L2fbM6bnfQrqaaJMxMaX6rM")
        GMSPlacesClient.provideAPIKey("AIzaSyDQxXl3_hh1L2fbM6bnfQrqaaJMxMaX6rM")

        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, error) in
            if !accepted {
                print("Notification access denied.")
            }
        }
        
        let actionDismiss1Hour = UNNotificationAction(identifier: "dismiss1hr", title: "Dismiss for an hour", options: [])
        let actionDismiss1Day = UNNotificationAction(identifier: "dismiss1day", title: "Dismiss for a day", options: [])
        let actionDismissEver = UNNotificationAction(identifier: "dismissforever", title: "Dismiss forever", options: [])
        let category = UNNotificationCategory(identifier: "myCategory", actions: [actionDismiss1Hour, actionDismiss1Day, actionDismissEver], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        
        return true
    }

    func changeRootController(){
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }
    
    func updateRemindersForUser(){
        ref.child("reminders").child(currentUser!).observe(.value, with: { (snapshot) in
            print("Reminders for \(currentUser!): \(snapshot.childrenCount)")
            
            if snapshot.childrenCount > 0{
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot{
                    if dismissedReminders[rest.key] == nil && activeReminders[rest.key] == nil && upcomingReminders[rest.key] == nil{
                        print("Firebase Index : \(rest.key)")
                        
                        let byUser = rest.childSnapshot(forPath: "byUser").value as! String
                        //print("By User: \(byUser)")
                        let description = rest.childSnapshot(forPath: "description").value as! String
                        //print("Notification Description: \(description)")
                        let date = self.getDateFromString(rest.childSnapshot(forPath: "date").value as! String)
                        //print(date)
                        let reminderStatus = rest.childSnapshot(forPath: "reminderStatus").value as! String
                        
                        let distanceString = rest.childSnapshot(forPath: "distance").value as? String
                        
                        var distance: Int = 200
                        if(distanceString != nil && Int(distanceString!) != nil){
                            distance = Int(distanceString!)!
                        }
                        
                        let lat = Double(rest.childSnapshot(forPath: "latitude").value as! String)
                        print("Latitude: \(lat)")
                        let lon = Double(rest.childSnapshot(forPath: "longitude").value as! String)
                        print("Longitude: \(lon)")
                        
                        var reminder:Reminder?
                        
                        //check if Userbased reminder
                        if rest.hasChild("forUser"){
                            let forUser = rest.childSnapshot(forPath: "forUser").value as! String
                            let fireBaseForIndex = rest.childSnapshot(forPath: "fireBaseForIndex").value as! String
                            
                            reminder = Reminder(forUser: forUser, byUser: byUser, date: date, description: description, distance:distance, latitude: lat!, longitude: lon!)
                            reminder!.fireBaseForIndex = fireBaseForIndex
                        }else{
                            // landmarkbased reminder
                            //print("landmark based reminder")

                            let locationName = rest.childSnapshot(forPath: "locationName").value as! String
                            
                            reminder = Reminder(byUser: byUser, date: date, description: description, locationName: locationName, distance:distance, latitude: lat!, longitude: lon!)
                        }
                        
                        reminder!.fireBaseByIndex = rest.key
                        
                        if reminderStatus == "dismissed"{
                            reminder!.reminderStatus = .dismissed
                            dismissedReminders[rest.key] = reminder
                        }else if reminder!.reminderStatus == .active{
                            activeReminders[rest.key] = reminder
                        }else{
                            upcomingReminders[rest.key] = reminder
                            Timer.scheduledTimer(timeInterval: reminder!.date.timeIntervalSinceNow, target: self, selector: #selector(self.updateReminders), userInfo: reminder!, repeats: false)
                        }
                    }else if activeReminders[rest.key] != nil && activeReminders[rest.key]!.forUser != nil && self.locationUpdated(rest, activeReminders[rest.key]!){
                        print("Location for reminder updated")
                    }else if upcomingReminders[rest.key] != nil && upcomingReminders[rest.key]!.forUser != nil && self.locationUpdated(rest, upcomingReminders[rest.key]!){
                        print("Location for reminder updated")
                    }
                }
                
                let homeViewController = self.window?.rootViewController as! HomeViewController
                homeViewController.updateActiveReminders()
                self.updateRemindersOnView()
                
                print(activeReminders.count)
                print(upcomingReminders.count)
                print(dismissedReminders.count)
            }
        })
        
        ref.child("forReminders").child(currentUser!).observe(.value, with: { (snapshot) in
            print("For Reminders for \(currentUser!): \(snapshot.childrenCount)")
            
            if snapshot.childrenCount > 0{
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot{
                    if dismissedForReminders[rest.key] == nil && activeForReminders[rest.key] == nil && upcomingForReminders[rest.key] == nil{
                        //print("Firebase Index : \(rest.key)")
                        
                        let forUser = rest.childSnapshot(forPath: "forUser").value as! String
                        //print("For User: \(forUser)")
                        let byUser = rest.childSnapshot(forPath: "byUser").value as! String
                        //print("By User: \(byUser)")
                        let description = rest.childSnapshot(forPath: "description").value as! String
                        //print("Notification Description: \(description)")
                        let date = self.getDateFromString(rest.childSnapshot(forPath: "date").value as! String)
                        //print(date)
                        let distanceString = rest.childSnapshot(forPath: "distance").value as? String
                        
                        var distance: Int = 200
                        if(distanceString != nil && Int(distanceString!) != nil){
                            distance = Int(distanceString!)!
                        }
                        
                        let reminderStatus = rest.childSnapshot(forPath: "reminderStatus").value as! String
                        
                        let lat = Double(rest.childSnapshot(forPath: "latitude").value as! String)
                        
                        let lon = Double(rest.childSnapshot(forPath: "longitude").value as! String)
                        
                        let fireBaseByIndex = rest.childSnapshot(forPath: "fireBaseByIndex").value as! String
                        
                        let reminder: Reminder = Reminder(forUser: forUser, byUser: byUser, date: date, description: description, distance:distance, latitude: lat!, longitude: lon!)
                        
                        reminder.fireBaseForIndex = rest.key
                        reminder.fireBaseByIndex = fireBaseByIndex
                        
                        if reminderStatus == "dismissed"{
                            reminder.reminderStatus = .dismissed
                            dismissedForReminders[rest.key] = reminder
                        }else if reminder.reminderStatus == .active{
                            activeForReminders[rest.key] = reminder
                        }else{
                            upcomingForReminders[rest.key] = reminder
                            Timer.scheduledTimer(timeInterval: reminder.date.timeIntervalSinceNow, target: self, selector: #selector(self.updateReminders), userInfo: reminder, repeats: false)
                        }
                    }else if activeForReminders[rest.key] != nil && self.statusUpdated(rest, activeForReminders[rest.key]!){
                        // update the date and status of a reminder
                        print("Status for reminder updated")
                    }
                }
                
                let homeViewController = self.window?.rootViewController as! HomeViewController
                homeViewController.updateActiveReminders()
                self.updateRemindersOnView()
                
                print(activeForReminders.count)
                print(upcomingForReminders.count)
                print(dismissedForReminders.count)
            }
        })
    }
    
    // check to see if status updated of a for Reminder and update status accordingly
    func statusUpdated(_ rest: FIRDataSnapshot, _ reminder: Reminder) -> Bool{
        let reminderStatus = rest.childSnapshot(forPath: "reminderStatus").value as! String
        let date = self.getDateFromString(rest.childSnapshot(forPath: "date").value as! String)
        
        if reminderStatus != reminder.getReminderStatus(){
            // check if updated to dismissed
            if reminderStatus == "dismissed"{
                let date = self.getDateFromString(rest.childSnapshot(forPath: "date").value as! String)
                dismissedForReminders[reminder.fireBaseForIndex] = reminder
                reminder.reminderStatus = .dismissed
                reminder.date = date
                activeForReminders.removeValue(forKey: reminder.fireBaseForIndex)
            }else if reminderStatus == "upcoming" && date > Date(){
                print("Status will be updated")
                let date = self.getDateFromString(rest.childSnapshot(forPath: "date").value as! String)
                upcomingForReminders[reminder.fireBaseForIndex] = reminder
                reminder.reminderStatus = .upcoming
                reminder.date = date
                activeForReminders.removeValue(forKey: reminder.fireBaseForIndex)
                Timer.scheduledTimer(timeInterval: reminder.date.timeIntervalSinceNow, target: self, selector: #selector(self.updateReminders), userInfo: reminder, repeats: false)
            }
            
            return true
        }
        
        return false
    }
    
    // check to see if location updated for a user reminder at the firebase database
    func locationUpdated(_ rest: FIRDataSnapshot , _ reminder: Reminder) -> Bool{
        let lat = Double(rest.childSnapshot(forPath: "latitude").value as! String)
        let lon = Double(rest.childSnapshot(forPath: "longitude").value as! String)
        
        //print(rest.key)
        //print(rest.childSnapshot(forPath: "latitude").value as! String)
        //print("Lat \(lat!) - \(reminder.latitude!)")
        //print("Lon \(lon!) - \(reminder.longitude!)")
    
        reminder.latitude = lat!
        reminder.longitude = lon!
        
        return true
    }
    
    //function to change status of upcoming reminders to active reminders
    func updateReminders(timer: Timer){
        print("update called")
        let reminder: Reminder = timer.userInfo as! Reminder
        var changed: Bool = false
        
        if upcomingReminders[reminder.fireBaseByIndex] != nil{
            activeReminders[reminder.fireBaseByIndex] = reminder
            upcomingReminders.removeValue(forKey: reminder.fireBaseByIndex)
            changed = true
        }else if upcomingForReminders[reminder.fireBaseForIndex] != nil{
            print("called")
            activeForReminders[reminder.fireBaseForIndex] = reminder
            upcomingForReminders.removeValue(forKey: reminder.fireBaseForIndex)
            changed = true
        }
        
        if changed{
            let homeViewController = self.window?.rootViewController as! HomeViewController
            homeViewController.updateActiveReminders()
            updateRemindersOnView()
        }
    }
    
    func getDateFromString(_ dateString: String) -> Date{
        //print("Date: \(dateString)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
        
        return dateFormatter.date(from: dateString)!
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("App enters background")
        appInBackground = true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("App enters foreground")
        appInBackground = false
        if currentUser != nil{
            let homeViewController = self.window?.rootViewController as! HomeViewController
            homeViewController.updateActiveReminders()
            updateRemindersOnView()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Remind_Me")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    func scheduleNotification(at date: Date, reminder: Reminder) {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute, second: components.second!+1)
        
        print(newComponents)
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "RemindMe"
        content.body = getTextDescription(reminder)
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "myCategory"
        
        if let path = Bundle.main.path(forResource: "logo", ofType: "png") {
            let url = URL(fileURLWithPath: path)
            
            do {
                let attachment = try UNNotificationAttachment(identifier: "logo", url: url, options: nil)
                content.attachments = [attachment]
            } catch {
                print("The attachment was not loaded.")
            }
        }
        
        let request = UNNotificationRequest(identifier: "remindMe:"+reminder.fireBaseByIndex, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }
    
    func getTextDescription(_ reminder: Reminder) -> String{
        var str = "You are near: "
        
        // if reminder is user based
        if(reminder.forUser != nil){
            str += reminder.forUser!
        }else{
            // if reminder is landmark based
            str += reminder.locationName!
        }
        
        str += ". "
        
        str += reminder.description
        
        return str;
    }
    
    func nearBy(lat:Double, lon:Double, reminder:Reminder)
    {
        if(lat != 0.0 && reminder.latitude != nil && reminder.latitude! != 0.0){
            let cordinate0 = CLLocation(latitude: lat,longitude: lon)
            let cordinate1 = CLLocation(latitude: reminder.latitude!, longitude: reminder.longitude!)
            
            let distanceInMeters: CLLocationDistance = cordinate0.distance(from: cordinate1)
            
            if reminder.forUser != nil{
                print("For : \(reminder.forUser!)")
            }else{
                print("For : \(reminder.locationName!)")
            }
            
            print("Distance \(distanceInMeters)")
            
            if !reminder.notified && distanceInMeters <= Double(reminder.distance){
                print("Distance less than \(reminder.distance)")
                reminder.notified = true
                scheduleNotification(at: Date(), reminder: reminder)
                let homeViewController = self.window?.rootViewController as! HomeViewController
                homeViewController.updateActiveReminders()
                updateRemindersOnView()
            }
        }
    }
    
    // check if any tab bar controller is opened and call reload on their table data view
    func updateRemindersOnView(){
        print("Check current view controller")
        print(self.window?.currentViewController() ?? "Not found")
        let tabBar = self.window?.currentViewController() as? UITabBarController
        if tabBar != nil{
            print("Selected Index - \(tabBar!.selectedIndex)")
            if tabBar!.selectedIndex == 0{
                let viewController = tabBar!.viewControllers![0] as? ActiveRemindersViewController
                if(viewController != nil && viewController!.isViewLoaded){
                    viewController!.updateReminders()
                }
            }else if tabBar!.selectedIndex == 2{
                let viewController =  tabBar!.viewControllers![2] as? DismissedRemindersViewController
                if(viewController != nil && viewController!.isViewLoaded){
                    viewController!.updateReminders()
                }
            }else{
                let viewController = tabBar!.viewControllers![1] as? UpcomingRemindersViewController
                if(viewController != nil && viewController!.isViewLoaded){
                    viewController!.updateReminders()
                }
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        var dismissCalled: Bool = false
        
        // dismiss the reminder
        if response.actionIdentifier == "dismissforever" {
            
            let dismissedDate = Date()
            let str = response.notification.request.identifier
            let reminderByIndex = str.substring(from: str.index(after: "remindMe:".endIndex))
            print("FirebaseByIndex from \(str): \(reminderByIndex)")
            
            if(activeReminders[reminderByIndex] == nil){
                let alertController = UIAlertController(title: "Dismiss Error", message: "The notification is of a stale reminder. Please go to the app and perform appropriate action from there", preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "Return", style:UIAlertActionStyle.default, handler: nil))
                
                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                return
            }
            
            // move this reminder from activeReminders to dismissed reminders
            dismissedReminders[reminderByIndex] = activeReminders[reminderByIndex]
            activeReminders.removeValue(forKey: reminderByIndex)
            
            let reminder = dismissedReminders[reminderByIndex]
            reminder!.date = dismissedDate
            reminder!.reminderStatus = .dismissed
            
            if(reminder!.fireBaseForIndex != nil){
                ref.child("forReminders").child(reminder!.forUser).child(reminder!.fireBaseForIndex).updateChildValues(["date": reminder!.date.description, "reminderStatus": reminder!.getReminderStatus()])
            }
            ref.child("reminders").child(reminder!.byUser).child(reminder!.fireBaseByIndex).updateChildValues(["date": reminder!.date.description, "reminderStatus": reminder!.getReminderStatus()])
            
            dismissCalled = true
        }else if response.actionIdentifier.hasPrefix("dismiss"){
            var newDate = Date()
            
            if response.actionIdentifier == "dismiss1hr"{
                newDate.addTimeInterval(3600)
            }else if response.actionIdentifier == "dismiss1day"{
                newDate.addTimeInterval(86400)
            }
            
            let str = response.notification.request.identifier
            let reminderByIndex = str.substring(from: str.index(after: "remindMe:".endIndex))
            print("FirebaseByIndex from \(str): \(reminderByIndex)")
            
            if(activeReminders[reminderByIndex] == nil){
                let alertController = UIAlertController(title: "Dismiss Error", message: "The notification is of a stale reminder. Please go to the app and perform appropriate action from there", preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "Return", style:UIAlertActionStyle.default, handler: nil))
                
                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                return
            }
            
            // move this reminder from activeReminders to dismissed reminders
            upcomingReminders[reminderByIndex] = activeReminders[reminderByIndex]
            activeReminders.removeValue(forKey: reminderByIndex)
            
            let reminder = upcomingReminders[reminderByIndex]
            reminder!.date = newDate
            reminder!.notified = false
            reminder!.reminderStatus = .upcoming
            
            if(reminder!.fireBaseForIndex != nil){
                ref.child("forReminders").child(reminder!.forUser).child(reminder!.fireBaseForIndex).updateChildValues(["date": reminder!.date.description, "reminderStatus": reminder!.getReminderStatus()])
            }
            
            ref.child("reminders").child(reminder!.byUser).child(reminder!.fireBaseByIndex).updateChildValues(["date": reminder!.date.description, "reminderStatus": reminder!.getReminderStatus()])
            
            dismissCalled = true;
        }
        
        if dismissCalled{
            let homeViewController = self.window?.rootViewController as! HomeViewController
            homeViewController.updateActiveReminders()
            updateRemindersOnView()
        }
    }
    
    //This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
        if notification.request.identifier.hasPrefix("remindMe:"){
            
            completionHandler( [.alert,.sound,.badge])
            
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        
        // Look for latest coordinate on maps
        let latitude: String = mostRecentLocation.coordinate.latitude.description
        let longitude: String = mostRecentLocation.coordinate.longitude.description
        
        print("Latitude \(latitude)")
        print("Longitude \(longitude)")
        
        myLat = Double(latitude)!
        myLon = Double(longitude)!
        
        // update location at all active for reminders who require this user's location
        for reminder in Array(activeForReminders.values){
            ref.child("reminders").child(reminder.byUser).child(reminder.fireBaseByIndex).updateChildValues(["latitude": latitude, "longitude": longitude])
        }
        
        // uncomment this if problem still persists
        //for reminder in Array(upcomingForReminders.values){
        //    ref.child("reminders").child(reminder.byUser).child(reminder.fireBaseByIndex).updateChildValues(["latitude": latitude, "longitude": longitude])
        //}
        
        // logic to check all active reminders and notify user
        for reminder in Array(activeReminders.values){
            if(!reminder.notified){
                nearBy(lat: myLat, lon: myLon, reminder: reminder)
            }
        }
        
    }
    
}

