//
//  ContentView.swift
//  Todo_List_App
//
//  Created by Tushar Gusain on 12/02/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var todoListModel: TodoListModel
    @State var newListDocument = ""
    @State var isPresented = false
    @State var importURL: URL? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section(header: Text("Add a new Document?")) {
                        HStack {
                            TextField("new Document", text: $newListDocument)
                            Button(action: {
                                self.addFolder()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                    .imageScale(.large)
                            }
                        }
                    }
                    .font(.headline)
                    Section(header: Text("Documents")) {
                        ForEach(self.todoListModel.folderLists) { list in
                            ListFolderView(folder: list).environmentObject(self.todoListModel)
                        }
                        .onDelete(perform: delete)
                    }
                }
            }.onAppear{
                self.todoListModel.fetchAllItemFolders()
            }
            .navigationBarTitle(Text("To-do List App"))
            .navigationBarItems(
                leading: Button(action: {
                    self.importDocument()
                }, label: {
                    Text("Import")
                }),
                trailing: EditButton()
            )
                .sheet(isPresented: $isPresented, onDismiss: {
                    if let _importURL = self.importURL {
                        self.todoListModel.importCSV(fileURL: _importURL) { imported in
                            print("Import = ", imported)
                        }
                    }
                }) {
                    DocumentPicker(isPresented: self.$isPresented, importURL: self.$importURL)
            }
        }
    }
    
    private func addFolder() {
        if newListDocument != "" {
            todoListModel.createNewFolder(name: newListDocument) { created in
                if created {
                    self.newListDocument = ""
                }
                print("created folder = ",created)
            }
        }
    }
    
    private func importDocument() {
        isPresented = true
    }
    
    private func delete(at offsets: IndexSet) {
        if let index = offsets.first {
            todoListModel.deleteItem(list: todoListModel.folderLists[index])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(TodoListModel.shared)
    }
}
