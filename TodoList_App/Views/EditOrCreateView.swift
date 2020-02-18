//
//  EditOrCreateView.swift
//  TodoList_App
//
//  Created by Tushar Gusain on 17/02/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import SwiftUI

struct EditOrCreateView: View {
    
    @EnvironmentObject var todoListModel: TodoListModel
    @Binding var list: ListDocument
    @Binding var isPresented: Bool
    
    @State var todoItem: TodoItem? = nil
    @State var todoItemTitle = ""
    @State var todoItemIsPending = false
    @State var todoItemDueDate = Date()
    
    var body: some View {
        VStack {
            TextField("new Title", text: $todoItemTitle)
            .padding()
            
            Toggle(isOn: $todoItemIsPending) {
                Text("Pending")
            }
            .padding()
            DatePicker(selection: $todoItemDueDate) {
                Text("Deadline")
            }
            .padding()
            Button(action: {
                self.saveItem()
            }) {
                Text("Save")
            }
            .padding()
            
        }.onAppear {
            if let _todoItem = self.todoItem {
                self.todoItemTitle = _todoItem.title!
                self.todoItemIsPending = _todoItem.isPending
                self.todoItemDueDate = _todoItem.dueDate!
            }
        }
    }
    
    private func saveItem() {
        if let _todoItem = todoItem {
            todoListModel.editTodoListItem(list: list, item: _todoItem, title: todoItemTitle, isPending: todoItemIsPending, dueDate: todoItemDueDate) { saved in
                if saved {
                    self.isPresented = false
                } else {
                    print("Not saved")
                }
            }
        } else {
            todoListModel.addTodoListItem(list: list, title: todoItemTitle, dueDate: todoItemDueDate, isPending: todoItemIsPending) { savedTodoItem in
                if let _savedTodoItem = savedTodoItem {
                    self.todoItem = _savedTodoItem
                    self.isPresented = false
                } else {
                    print("Not able to allocate todoItem")
                }
            }
        }
    }
}

//struct EditOrCreateView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditOrCreateView().environmentObject(TodoListModel.shared)
//    }
//}
