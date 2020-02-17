//
//  TodoStoreManager.swift
//  Todo_List_App
//
//  Created by Tushar Gusain on 13/02/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class TodoStoreManager {
    
    //MARK:- Property Variables
    
    private let todoItemEntity = "TodoItem"
    private let listEntity = "ListDocument"
    private var persistenceContainer: NSPersistentContainer?
    private lazy var backGroundContext: NSManagedObjectContext? = {
        self.persistenceContainer?.viewContext //newBackgroundContext()
    }()
    
    static var shared = TodoStoreManager()
    
    //MARK:- Initializers
    
    init(container: NSPersistentContainer?) {
        self.persistenceContainer = container
        persistenceContainer!.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    private convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error getting App Delegate")
            self.init(container: nil)
            return
        }
        self.init(container: appDelegate.persistentContainer)
    }
    
    //MARK:- CRUD Methods
    
    func fetchAll() -> [ListDocument] {
        let request: NSFetchRequest<ListDocument> = ListDocument.fetchRequest()

        let results = try? persistenceContainer?.viewContext.fetch(request)
        return results ?? []
    }
    
    func createList(title: String) -> ListDocument? {
        guard let _backgroundContext = backGroundContext else {
                return nil
        }
        
        let newList = ListDocument(context: _backgroundContext)
        
        newList.id = UUID()
        newList.name = title
        
        save { saved in
            print("new list saved = ", saved)
            print("List: ", newList)
        }
        
        return newList
    }
    
    func getTodoItem(for list: ListDocument) -> [TodoItem] {
        let todoItemSet = list.todoItem
        let todoItemArray = todoItemSet?.allObjects as? [TodoItem]
        
        return todoItemArray ?? []
    }
    
    func insertTodoItemInList(list: ListDocument, id: UUID = UUID(), title: String, isPending: Bool = true, dueDate: Date) -> TodoItem? {
        guard let _backgroundContext = backGroundContext else {
                return nil
        }
        
        let newItem = TodoItem(context: _backgroundContext)
        newItem.id = id
        newItem.title = title
        newItem.isPending = isPending
        newItem.dueDate = dueDate
                 
        newItem.listDocument = list
        list.addToTodoItem(newItem)
        
        save { saved in
            print("new item saved = ", saved)
            print("Todo item: ", newItem)
            print("List in which it was added: ", list)
        }
        
        return newItem
    }
    
    func removeItem(itemID: NSManagedObjectID, completion: @escaping (Bool) -> Void) {
        guard let _backgroundContext = backGroundContext else {
            completion(false)
            return
        }
        let item = _backgroundContext.object(with: itemID)
        _backgroundContext.delete(item)
        
        save { saved in
            print("item deleted = ", item)
        }
        
        completion(true)
    }
    
    func save(completion: @escaping (Bool) -> Void) {
        guard let _backGroundContext = backGroundContext else {
            completion(false)
            return
        }
        if _backGroundContext.hasChanges {
            do {
                try _backGroundContext.save()
                completion(true)
            } catch {
                completion(false)
                print("Error saving the context: ",error)
            }
        }
    }
    
}
