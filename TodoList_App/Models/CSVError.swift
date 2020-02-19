//
//  CSVError.swift
//  Todo_List_App
//
//  Created by Tushar Gusain on 14/02/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation

enum CSVError: String, Error {
    case ImportError = "Error getting contents of the file"
    case ExportError = "Error exporting the file to CSV"
    case IllFormatedDateError = "Date is not in specified format"
    case MemoryNotAllocatedError = "Unable to allocate memory for the object"
    case DocumentAlreadyExists = "Import document already exists"
}
