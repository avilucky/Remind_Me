//
//  Reminder.swift
//  Remind_Me
//
//  Created by Avinash Talreja on 11/5/16.
//  Copyright © 2016 Avinash Talreja. All rights reserved.
//

import Foundation

enum EventType{
    case nearby, reached, leaving
}

enum ReminderStatus{
    case active, upcoming, dismissed
}

class Reminder{
    var fireBaseIndex: String!
    var forUser: String!
    var byUser: String
    var date: Date
    var description: String
    var locationName: String!
    var latitude: Double!
    var longitude: Double!
    var eventType: EventType = .nearby
    var reminderStatus: ReminderStatus
    var notified: Bool = false
    
    // this initializer will be used never , kept 
    // for reference, TODO will be removed in the final phase
    init(fireBaseIndex: String, forUser: String, byUser: String, date: Date, description: String, locationName: String, latitude: Double, longitude: Double, eventType: EventType, reminderStatus: ReminderStatus) {
        
        self.fireBaseIndex = fireBaseIndex
        self.forUser = forUser
        self.byUser = byUser
        self.date = date
        self.description = description
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.eventType = eventType
        self.reminderStatus = reminderStatus
    }
    
    // this initializer will be used when saving user based reminders
    init(forUser: String, byUser: String, date: Date, description: String) {
        self.forUser = forUser
        self.byUser = byUser
        self.date = date
        self.description = description
        self.reminderStatus = .upcoming
        
        if isActive(date){
            self.reminderStatus = .active
        }
    }
    
    // this initializer will be used when storing location based reminders
    init(byUser: String, date: Date, description: String, locationName: String, latitude: Double, longitude: Double, eventType: EventType) {
        
        self.byUser = byUser
        self.date = date
        self.description = description
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.eventType = eventType
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
    
    func getEventType() -> String{
        if self.eventType == .leaving{
            return "leaving"
        }else if self.eventType == .nearby{
            return "nearby"
        }else{
            return "reached"
        }
    }
}
