//
//  ToDoItem.swift
//  ToDoApp
//
//  Created by Sneh on 17/09/18.
//  Copyright © 2018 The Gateway Corp. All rights reserved.
//

import Foundation

struct ToDoItem: Codable {
    
    var title: String
    var completed: Bool
    var createdAt: Date //Used to sort items
    var itemIdentifier: UUID
    
    func saveItem(){
        DataManager.save(self, with: itemIdentifier.uuidString) //Converting this DataModel obj into JSON nd storing it on App Side
    }
    
    func deleteItem(){
        DataManager.delete(itemIdentifier.uuidString)
    }
    
    mutating func markAsCompleted(){
        self.completed = true
        DataManager.save(self, with: itemIdentifier.uuidString)
    }
    
}
