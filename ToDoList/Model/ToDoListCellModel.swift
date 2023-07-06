//
//  ToDoListCellModel.swift
//  ToDoList
//
//  Created by Nik Kozhemyakin on 01.07.2023.
//

import UIKit

class ToDoListCellModel {
    var todoItem: ToDoItem
    var index: Int
    
    init(todoItem: ToDoItem, index: Int) {
        self.todoItem = todoItem
        self.index = index
    }
    
    func toggleIsDone() {
        let new = ToDoItem(id: todoItem.id, text: todoItem.text, deadline: todoItem.deadline, importance: todoItem.importance, isDone: !todoItem.isDone, created: todoItem.created,
                           changed: todoItem.changed)
        todoItem = new
    }
}
