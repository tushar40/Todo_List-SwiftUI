//
//  NotificationScheduler.swift
//  TodoList_App
//
//  Created by Tushar Gusain on 18/02/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit.UIImage

class NotificationManager: NSObject {
    
    //MARK:- Property Variables
    private let notificationCenter = UNUserNotificationCenter.current()
    static var shared = NotificationManager()
    
    //MARK:- Initializers
    
    private override init() {
        super.init()
        registerNotification()
    }
    
    //MARK:- Methods
    
    func registerNotification() {
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Status granted")
            } else {
                print("Request not granted")
            }
        }
    }
    
    func scheduleNotification(todoItem: TodoItem) {
        notificationCenter.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                let content = UNMutableNotificationContent()
                content.title = todoItem.title!
                content.body = "Deadline for \(todoItem.title!) reached"
                content.categoryIdentifier = "TIMER_EXPIRED"
                content.sound = .default
                       
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: todoItem.dueDate!)
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                
                let request = UNNotificationRequest(identifier: todoItem.id!.uuidString, content: content, trigger: trigger)
                
                self.notificationCenter.add(request) { error in
                    print("Error in scheduling notification, error: ", error)
                }
            } else {
                print("Notification permission is not granted")
            }
        }
    }
    
    func removeNotification(id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
}

//MARK:- UNUserNotificationDelegate Methods

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Got the notification in foreground")
        
        completionHandler([.alert, .badge, .sound])
    }
}
