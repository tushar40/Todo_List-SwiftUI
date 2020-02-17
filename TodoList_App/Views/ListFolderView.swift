//
//  ListFolderView.swift
//  Todo_List_App
//
//  Created by Tushar Gusain on 14/02/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import SwiftUI

struct ListFolderView: View {
    
    @EnvironmentObject var todoListModel: TodoListModel
    @State var folder: ListDocument
    
    var body: some View {
        HStack {
            Image(systemName: "folder")
                .padding()
            NavigationLink(destination: TodoListView(folder: $folder).environmentObject(todoListModel)) {
                Text("\(folder.name ?? "deleting...")")
            }
            .padding()
            Spacer()
        }
    }

}

//struct ListFolderView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListFolderView().environmentObject(TodoListModel.shared)
//    }
//}

