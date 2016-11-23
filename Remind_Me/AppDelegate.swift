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

var activeReminders: [String: Reminder] = [String: Reminder]()
var activeForReminders: [String: Reminder] = [String: Reminder]()
var dismissedReminders: [String: Reminder] = [String: Reminder]()
var dismissedForReminders: [String: Reminder] = [String: Reminder]()
var upcomingReminders: [String: Reminder] = [String: Reminder]()
var upcomingForReminders: [String: Reminder] = [String: Reminder]()

var appInBackground: Bool = false

let defaults = UserDefaults.standard
var currentUser: String? = defaults.object(forKey: "username") as? String

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
        
        // start updating locations
        locationManager.startUpdatingLocation()
        
        // Override point for customization after application launch.
        FIRApp.configure()
        
        ref = FIRDatabase.database().reference()
        
        // enable key sharing from project settings if this doesn't print anything
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value)
        })
        
        // we check for any username associated with the phone
        let username:String? = currentUser
        
        // for testing purpose comment the above declaration and use the below one
        // let username:String? = "avinash1"
        
        print("User: \(username)")
        
        if username != nil{
            // if yes that is phone has already registered for the app, then look if the 
            // details of the users exist on firebase
            ref.child("users").child(username!).observeSingleEvent(of: .value, with: { (snapshot) in
                // if user details exist on firebase then set the root controller to the HomeViewController
                //print("Sanpshot children count: \(snapshot.childrenCount)")
                if snapshot.childrenCount > 0{
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
                    
                    self.window?.rootViewController = initialViewController
                    self.window?.makeKeyAndVisible()
                    
                    self.updateRemindersForUser()
                }
            })
        }
        GMSServices.provideAPIKey("AIzaSyDQxXl3_hh1L2fbM6bnfQrqaaJMxMaX6rM")
        GMSPlacesClient.provideAPIKey("AIzaSyDQxXl3_hh1L2fbM6bnfQrqaaJMxMaX6rM")

        return true
    }

    func updateRemindersForUser(){
        ref.child("reminders").child(currentUser!).observe(.value, with: { (snapshot) in
            print("Reminders for \(currentUser!): \(snapshot.childrenCount)")
            
            if snapshot.childrenCount > 0{
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot{
                    if dismissedReminders[rest.key] == nil && activeReminders[rest.key] == nil && upcomingReminders[rest.key] == nil{
                        //print("Firebase Index : \(rest.key)")
                        
                        let byUser = rest.childSnapshot(forPath: "byUser").value as! String
                        //print("By User: \(byUser)")
                        let description = rest.childSnapshot(forPath: "description").value as! String
                        //print("Notification Description: \(description)")
                        let date = self.getDateFromString(rest.childSnapshot(forPath: "date").value as! String)
                        //print(date)
                        let reminderStatus = rest.childSnapshot(forPath: "reminderStatus").value as! String
                        
                        let lat = Double(rest.childSnapshot(forPath: "latitude").value as! String)
                        
                        let lon = Double(rest.childSnapshot(forPath: "longitude").value as! String)
                        
                        var reminder:Reminder?
                        
                        //check if Userbased reminder
                        if rest.hasChild("forUser"){
                            let forUser = rest.childSnapshot(forPath: "forUser").value as! String
                            let fireBaseForIndex = rest.childSnapshot(forPath: "fireBaseForIndex").value as! String
                            
                            reminder = Reminder(forUser: forUser, byUser: byUser, date: date, description: description, latitude: lat!, longitude: lon!)
                            reminder!.fireBaseForIndex = fireBaseForIndex
                        }else{
                            // landmarkbased reminder
                            //print("landmark based reminder")

                            let locationName = rest.childSnapshot(forPath: "locationName").value as! String
                            
                            
                            let eveType: EventType = EventType.getEventTypeEnum(eventType: rest.childSnapshot(forPath: "eventType").value as! String)
                            
                            reminder = Reminder(byUser: byUser, date: date, description: description, locationName: locationName, latitude: lat!, longitude: lon!, eventType: eveType)
                        }
                        
                        reminder!.fireBaseByIndex = rest.key
                        
                        if reminderStatus == "dismissed"{
                            reminder!.reminderStatus = .dismissed
                            dismissedReminders[rest.key] = reminder
                        }else if reminder!.reminderStatus == .active{
                            activeReminders[rest.key] = reminder
                        }else{
                            upcomingReminders[rest.key] = reminder
                        }
                    }else if activeReminders[rest.key] != nil && activeReminders[rest.key]?.forUser != nil && self.locationUpdated(rest, activeReminders[rest.key]!){
                        // TODO logic to check if location updated for an active reminder
                        // call notify if required by the reminder
                        print("Location for reminder updated")
                    }
                }
                
                let homeViewController = self.window?.rootViewController as! HomeViewController
                homeViewController.updateActiveReminders()
                
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
                        let reminderStatus = rest.childSnapshot(forPath: "reminderStatus").value as! String
                        
                        let lat = Double(rest.childSnapshot(forPath: "latitude").value as! String)
                        
                        let lon = Double(rest.childSnapshot(forPath: "longitude").value as! String)
                        
                        let fireBaseByIndex = rest.childSnapshot(forPath: "fireBaseByIndex").value as! String
                        
                        let reminder: Reminder = Reminder(forUser: forUser, byUser: byUser, date: date, description: description, latitude: lat!, longitude: lon!)
                        
                        reminder.fireBaseForIndex = rest.key
                        reminder.fireBaseByIndex = fireBaseByIndex
                        
                        if reminderStatus == "dismissed"{
                            reminder.reminderStatus = .dismissed
                            dismissedForReminders[rest.key] = reminder
                        }else if reminder.reminderStatus == .active{
                            activeForReminders[rest.key] = reminder
                        }else{
                            upcomingForReminders[rest.key] = reminder
                        }
                    }
                }
                
                let homeViewController = self.window?.rootViewController as! HomeViewController
                homeViewController.updateActiveReminders()
                
                print(activeForReminders.count)
                print(upcomingForReminders.count)
                print(dismissedForReminders.count)
            }
        })
    }
    
    // check to see if location updated for a user reminder at the firebase database
    func locationUpdated(_ rest: FIRDataSnapshot , _ reminder: Reminder) -> Bool{
        let lat = Double(rest.childSnapshot(forPath: "latitude").value as! String)
        let lon = Double(rest.childSnapshot(forPath: "longitude").value as! String)
        
        //print(rest.key)
        //print(rest.childSnapshot(forPath: "latitude").value as! String)
        //print("Lat \(lat!) - \(reminder.latitude!)")
        //print("Lon \(lon!) - \(reminder.longitude!)")
        
        if lat == reminder.latitude && lon == reminder.longitude{
            print("It's same")
            return false
        }
        
        reminder.latitude = lat!
        reminder.longitude = lon!
        print("Updated")
        
        return true
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
        let homeViewController = self.window?.rootViewController as! HomeViewController
        homeViewController.updateActiveReminders()
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
        
        // update location at all active for reminders who require this user's location
        for reminder in Array(activeForReminders.values){
            ref.child("reminders").child(reminder.byUser).child(reminder.fireBaseByIndex).child("latitude").setValue(latitude)
            ref.child("reminders").child(reminder.byUser).child(reminder.fireBaseByIndex).child("longitude").setValue(longitude)
        }
        
        // TODO logic to check all active reminders and notify user
    }
    
}

