//
//  TodoListView.swift
//  Todo_List_App
//
//  Created by Tushar Gusain on 14/02/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import SwiftUI

struct TodoListView: View {
    @EnvironmentObject var todoListModel: TodoListModel
    @Binding var folder: ListDocument
    @State var isPresented = false
    @State var itemTapped: TodoItem? = nil
    
    var body: some View {
        ZStack {
                List {
                    Section(header: Text("To-Do Items")) {
                        ForEach(self.todoListModel.todoListDictionary[folder.id ?? UUID()] ?? []) { item in
                            HStack {
                                Image("\(item.isPending ? "pending": "checkmark")")
                                ////Image(systemName: "square.and.pencil")
                                Text(String(describing: item.title!))
                                Spacer()
                                Text(self.todoListModel.formatDate(date: item.dueDate!))
                                }
                            .padding()
                            .onTapGesture(count: 1) {
                                self.itemTapped = item
                                self.isPresented = true
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Button(action: {
                        self.itemTapped = nil
                        self.isPresented = true
                    }, label: {
                        Text("+")
                            .font(.system(.largeTitle))
                            .frame(width: 77, height: 70)
                            .foregroundColor(Color.white)
                            .padding(.bottom, 7)
                    })
                        .background(Color.blue)
                        .cornerRadius(38.5)
                        .padding()
                        .shadow(color: Color.black.opacity(0.3),
                                radius: 3,
                                x: 3,
                                y: 3)
                }
            }
        }
        .sheet(isPresented: $isPresented) {
            EditOrCreateView(list: self.$folder, isPresented: self.$isPresented, todoItem: self.itemTapped ).environmentObject(self.todoListModel)
        }
        .navigationBarTitle(Text("\(folder.name ?? "")"))
        .navigationBarItems(trailing: Button(action: {
            self.exportList()
        }, label: {
            Text("Export")
        }))
    }
    
    private func exportList() {
        todoListModel.exportToCSV(list: folder) { error in
            print("Exporting: error: ", error)
        }
    }
    
    private func delete(at offsets: IndexSet) {
        if let index = offsets.first {
            todoListModel.deleteItem(todoItem: todoListModel.todoListDictionary[folder.id!]![index])
        }
    }
    
}

//struct TodoListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TodoListView().environmentObject(TodoListModel.shared)
//    }
//}
