//
//  Reminder.swift
//  Remind_Me
//
//  Created by Avinash Talreja on 11/5/16.
//  Copyright © 2016 Avinash Talreja. All rights reserved.
//

import Foundation

enum ReminderStatus{
    case active, upcoming, dismissed
}

class Reminder{
    var fireBaseForIndex: String!
    var fireBaseByIndex: String!
    var forUser: String!
    var byUser: String
    var date: Date
    var description: String
    var locationName: String!
    var latitude: Double!
    var longitude: Double!
    var distance: Int
    var reminderStatus: ReminderStatus
    var notified: Bool = false
    
    // this initializer will be used never , kept 
    // for reference, TODO will be removed in the final phase
    init(fireBaseForIndex: String, fireBaseByIndex: String, forUser: String, byUser: String, date: Date, description: String, locationName: String, latitude: Double, longitude: Double, distance: Int, reminderStatus: ReminderStatus) {
        
        self.fireBaseForIndex = fireBaseForIndex
        self.fireBaseByIndex = fireBaseByIndex
        self.forUser = forUser
        self.byUser = byUser
        self.date = date
        self.description = description
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.distance = distance
        self.reminderStatus = reminderStatus
    }
    
    // this initializer will be used when saving user based reminders
    init(forUser: String, byUser: String, date: Date, description: String, distance: Int, latitude: Double, longitude: Double) {
        self.forUser = forUser
        self.byUser = byUser
        self.date = date
        self.description = description
        self.distance = distance
        self.latitude = latitude
        self.longitude = longitude
        self.reminderStatus = .upcoming
        
        if isActive(date){
            self.reminderStatus = .active
        }
    }
    
    // this initializer will be used when storing location based reminders
    init(byUser: String, date: Date, description: String, locationName: String, distance: Int, latitude: Double, longitude: Double) {
        
        self.byUser = byUser
        self.date = date
        self.description = description
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.distance = distance
        self.reminderStatus = .upcoming
        
        if isActive(date){
            self.reminderStatus = .active
        }
    }
    
    func isActive(_ date : Date) -> Bool{
        // add 2 minutes to the current Date to determine the status of the reminder
        let nowDate: Date = Date.init().addingTimeInterval(120)
        
        if date <= nowDate{
            return true
        }else{
            return false
        }
    }
    
    func getReminderStatus() -> String{
        if(self.reminderStatus == .active){
            return "active"
        }else if(self.reminderStatus == .upcoming){
            return "upcoming"
        }else{
            return "dismissed"
        }
    }
}
