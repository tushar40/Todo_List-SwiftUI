//
//  CSVPorter.swift
//  Todo_List_App
//
//  Created by Tushar Gusain on 12/02/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation

class CSVPorter {
    
    //MARK:- Property Variables
    
    private let fileManager = FileManager.default
    private let todoStoreManager = TodoStoreManager.shared
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY"
        return formatter
    }()
    
    static let shared = CSVPorter()
    
    //MARK:- Initializers
    
    private init() { }
    
    func exportToFile(list: ListDocument, items: [TodoItem], completion: @escaping (Error?) -> Void) {
        let exportString = createExportString(items: items)
        var exportFilePath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        exportFilePath = exportFilePath.appendingPathComponent("\(list.name!)_\(list.id!.uuidString).csv")
        print("Path to export file: ", exportFilePath)
        do {
            let data = exportString.data(using: .utf8)
            fileManager.createFile(atPath: exportFilePath.path, contents: data)
            let contents = try String(contentsOf: exportFilePath)
            print("File string: \n", contents)
            completion(nil)
        } catch {
            print("Error writing the file: ", error)
            completion(CSVError.ExportError)
        }
    }
    
    func importFile(fileUrl: URL, folderList: [ListDocument], completion: @escaping (Result<ListDocument, Error>) -> Void) {
        do {
            let contents = try String(contentsOf: fileUrl)
            let listTitleAndID = fileUrl.lastPathComponent.split(separator: "_").map({ String($0) })
            let listTitle = listTitleAndID[0]
            let uuidString = listTitleAndID[1].split(separator: ".").map({ String($0) })[0]
            let contentArray = getTodoItemStrings(fromString: contents)
            
            if let _ = folderList.map({ $0.name! }).firstIndex(of: listTitle) {
                completion(.failure(CSVError.DocumentAlreadyExists))
                return
            }
            let list = todoStoreManager.createList(title: listTitle)
            guard let _list = list else {
                completion(.failure(CSVError.MemoryNotAllocatedError))
                return
            }
            _list.name = listTitle
            _list.id = UUID(uuidString: uuidString)
            var items = [TodoItem]()
            for row in contentArray {
                let dueDate = dateFormatter.date(from: row[3])
                if let _dueDate = dueDate {
                    let item = todoStoreManager.insertTodoItemInList(list: _list, id: UUID(), title: row[1], isPending: row[2] == "true", dueDate: _dueDate)
                    if let _item = item {
                        items.append(_item)
                        _list.addToTodoItem(_item)
                        _item.listDocument = _list
                    }
                } else {
                    print("Error getting date: ",CSVError.IllFormatedDateError.rawValue)
                }
            }
            print("Imported file: \n", _list)
            print("Todo Items: \n", items)
            return completion(.success(_list))
        } catch {
            print("Error getting the contents of the file, error: ", error)
            completion(.failure(CSVError.ImportError))
        }
    }
    
    func formatDate(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    private func getTodoItemStrings(fromString: String) -> [[String]] {
        var contents = [[String]]()
        
        let rows = fromString.split(separator: "\n").map({ String($0) })
        
        for rowString in rows {
            let rowContent = rowString.split(separator: ",").map({ String($0) })
            contents.append(rowContent)
        }
        
        return Array<[String]>(contents[1...])
    }
    
    private func createExportString(items: [TodoItem]) -> String {
        var id: UUID
        var title: String
        var isPending: Bool
        var dueDate: Date
        
        var exportString = "Id,Title,Pending,Due Date"
        
        for item in items {
            id = item.id!
            title = item.title!
            isPending = item.isPending
            dueDate = item.dueDate!
            let dueDateString = formatDate(date: dueDate)
            
            exportString = "\(exportString)\n\(id.uuidString),\(title),\(isPending),\(dueDateString)"
        }
        
        return exportString
    }
    
}
