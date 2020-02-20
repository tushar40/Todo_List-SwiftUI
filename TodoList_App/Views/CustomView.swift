//
//  CustomView.swift
//  TodoList_App
//
//  Created by Tushar Gusain on 19/02/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation
import SwiftUI

struct CustomView: UIViewRepresentable {
    
    @EnvironmentObject var todoListModel: TodoListModel
    @Binding var presentAlert: Bool
    let maxLength = 30
    
    typealias UIViewType = UIStackView
    
    let textField = UITextField(frame: CGRect.zero)
    
    func makeUIView(context: UIViewRepresentableContext<CustomView>) -> CustomView.UIViewType {
        
        textField.placeholder = "new Document(<\(maxLength) Characters)"
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator.self, action: #selector(context.coordinator.textChanged(_:)), for: .editingChanged)
        
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.addTarget(context.coordinator.self, action: #selector(context.coordinator.storeValue(_:)), for: .touchUpInside)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = 16.0
        
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(button)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    func updateUIView(_ uiView: CustomView.UIViewType, context: UIViewRepresentableContext<CustomView>) {
        
    }
    
    func makeCoordinator() -> CustomView.Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        var parent: CustomView
        
        init(_ parent: CustomView) {
            self.parent = parent
        }
        
        private func addFolder(name: String?) {
            if name != nil && name != "" {
                parent.todoListModel.createNewFolder(name: name!) { created in
                    print("created folder = ",created)
                }
            } else {
               print("No name given")
                parent.presentAlert = true
            }
        }
        
        @objc func textChanged(_ textField: UITextField) {
            print(textField.text)
        }
        
        @objc func storeValue(_ button: Any) {
            parent.textField.resignFirstResponder()
            print(#function)
            addFolder(name: parent.textField.text)
            parent.textField.text = ""
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            print(textField.text)
            storeValue(textField)
            return true
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            return range.location < parent.maxLength
        }
    }
}
