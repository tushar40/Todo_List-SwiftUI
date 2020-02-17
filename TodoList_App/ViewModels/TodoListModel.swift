//
//  TodoListModel.swift
//  Todo_List_App
//
//  Created by Tushar Gusain on 13/02/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation

class TodoListModel: ObservableObject {
    
    //MARK:- Property Variables
    
    @Published var folderLists: [ListDocument] = []
    @Published var todoListDictionary: [UUID: [TodoItem]] = [:]
    
    private let todoStoreManager = TodoStoreManager.shared
    private let csvPorter = CSVPorter.shared
    
    static let shared = TodoListModel()
    
    //MARK:- Initializers
    
    private init() { }
    
    //MARK:- Member Functions
    
    func fetchAllItemFolders() {
        folderLists = todoStoreManager.fetchAll()
        for folder in folderLists {
            todoListDictionary[folder.id!] = fetchTodoItems(for: folder)
        }
    }
    
    func fetchTodoItems(for list: ListDocument) -> [TodoItem] {
        let todoItemsArray = todoStoreManager.getTodoItem(for: list)
        todoListDictionary[list.id!] = todoItemsArray
        return todoItemsArray
    }
    
    func createNewFolder(name: String, completion: @escaping (Bool) -> Void) {
        let list = todoStoreManager.createList(title: name)
        completion(list != nil)
        fetchAllItemFolders()
    }
    
    func addTodoListItem(list: ListDocument, title: String, dueDate: Date, completion: @escaping (TodoItem?) -> Void) {
        let item = todoStoreManager.insertTodoItemInList(list: list, title: title, dueDate: dueDate)
        fetchTodoItems(for: list)
        completion(item)
    }
    
    func editTodoListItem(list: ListDocument, item: TodoItem, title: String? = nil, isPending: Bool? = nil, dueDate: Date? = nil, completion: @escaping (Bool) -> Void) {
        if let _title = title {
            item.title = _title
        }
        if let _isPending = isPending {
            item.isPending = _isPending
        }
        if let _dueDate = dueDate {
            item.dueDate = _dueDate
        }
        saveToMemory { [weak self] saved in
            print("Editing saved = ", saved)
            self?.fetchTodoItems(for: list)
            completion(saved)
        }
    }
    
    func deleteItem(todoItem: TodoItem? = nil, list: ListDocument? = nil) {
        if let _todoItem = todoItem {
            todoStoreManager.removeItem(itemID: _todoItem.objectID) { deleted in
                if deleted {
                    self.fetchAllItemFolders()
                }
            }
        } else if let _list = list {
            todoStoreManager.removeItem(itemID: _list.objectID) { [unowned self] deleted in
                if deleted {
                    self.fetchAllItemFolders()
                }
            }
        } else {
            print("No item to delete, item doesn't exist")
        }
    }
    
    func saveToMemory(completion: @escaping (Bool) -> Void) {
        todoStoreManager.save() { saved in
            completion(saved)
        }
    }
    
    func importCSV(fileURL: URL, completion: @escaping (Result< ListDocument, Error>) -> Void) {
        csvPorter.importFile(fileUrl: fileURL) { result in
            completion(result)
        }
    }
    
    func exportToCSV(list: ListDocument, completion: @escaping (Error?) -> Void) {
        let items = list.todoItem?.allObjects as? [TodoItem]
        guard let _items = items else {
            completion(CSVError.ExportError)
            return
        }
        csvPorter.exportToFile(list: list, items: _items) { error in
            completion(error)
        }
    }
    
    func formatDate(date: Date) -> String {
        return csvPorter.formatDate(date: date)
    }
}
