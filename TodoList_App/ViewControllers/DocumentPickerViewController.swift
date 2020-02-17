//
//  DocumentPickerViewController.swift
//  TodoList_App
//
//  Created by Tushar Gusain on 17/02/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import SwiftUI
import UIKit
import MobileCoreServices

struct DocumentPicker: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    @Binding var importURL: URL?

    typealias UIViewControllerType = UIDocumentPickerViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> DocumentPicker.UIViewControllerType {
        let picker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText)], in: .open)
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {
        //
    }
    
    func makeCoordinator() -> DocumentPicker.Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        
        var parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print(urls)
            parent.importURL = urls.first
            parent.isPresented = false
        }
        
    }
}
