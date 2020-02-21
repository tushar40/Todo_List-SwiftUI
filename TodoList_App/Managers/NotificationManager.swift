//
//  NotificationScheduler.swift
//  TodoList_App
//
//  Created by Tushar Gusain on 18/02/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation
import SwiftUI
import UserNotifications
import UIKit.UIImage

fileprivate struct NotificationAction {
    static let openAction = "Open_Action"
    static let markAsDoneAction = "Mark_As_Done_Action"
}

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
    
    func scheduleNotification(todoItem: TodoItem, list: ListDocument) {
        notificationCenter.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                
                let openAction = UNNotificationAction(identifier: NotificationAction.openAction, title: "Open App", options: [.foreground])
                let markAsDoneAction = UNNotificationAction(identifier: NotificationAction.markAsDoneAction, title: "Mark as Done", options: [])
                
                let notificationCategory = UNNotificationCategory(identifier: todoItem.id!.uuidString, actions: [openAction, markAsDoneAction], intentIdentifiers: [], options: [])
                
                self.notificationCenter.setNotificationCategories([notificationCategory])
                
                let content = UNMutableNotificationContent()
                content.title = list.name!
                content.body = "Deadline for \(todoItem.title!) reached"
                content.categoryIdentifier = todoItem.id!.uuidString //"TIMER_EXPIRED"
                content.sound = .default
                       
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: todoItem.dueDate!)
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                                
                DispatchQueue.main.async {
                    content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
                    let request = UNNotificationRequest(identifier: todoItem.id!.uuidString, content: content, trigger: trigger)
                    self.notificationCenter.add(request) { error in
                        print("Error in scheduling notification, error: ", error)
                    }
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

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let application = UIApplication.shared

        print("Notification bar tapped when app state was: ", application.applicationState.rawValue)
        
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber -= 1
        }
        
        switch response.actionIdentifier {
        case NotificationAction.openAction:
            let scene = UIApplication.shared.connectedScenes.first

            if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                // Use a UIHostingController as window root view controller.
                sd.setUpRootScene()
            }
            
            completionHandler()
        case NotificationAction.markAsDoneAction:
            let id = response.notification.request.identifier
            
            let todoItems = TodoStoreManager.shared.fetchAllTodos()
                        
            for item in todoItems {
                if item.id!.uuidString == id {
                    item.isPending = false
                    TodoStoreManager.shared.save { _ in
                        TodoListModel.shared.fetchAllItemFolders()
                    }
                    break
                }
            }
            
        default:
            print("User selected some other action")
        }

//        let id = response.notification.request.identifier
//
//        let folders = TodoStoreManager.shared.fetchAll()
//
//        var listDocument: ListDocument?
//
//        for folder in folders {
//            if folder.id!.uuidString == id {
//                listDocument = folder
//                break
//            }
//        }
//
//        let todoListView = TodoListView(folder: listDocument).environmentObject(TodoListModel.shared)
//        let todoListController = UIHostingController(rootView: todoListView)
//
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        let navigationController = UINavigationController()
//
//        // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
//        // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
//        let contentView = ContentView().environment(\.managedObjectContext, context).environmentObject(TodoListModel.shared)
//
//        let contentViewController = UIHostingController(rootView: contentView)
//
//        navigationController.pushViewController(contentViewController, animated: true)
//        navigationController.pushViewController(todoListController, animated: true)

    }
}
