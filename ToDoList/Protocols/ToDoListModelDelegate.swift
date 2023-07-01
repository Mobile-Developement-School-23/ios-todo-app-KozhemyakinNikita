//
//  ToDoListModelDelegate.swift
//  ToDoList
//
//  Created by Nik Kozhemyakin on 30.06.2023.
//

import Foundation

protocol ToDoListModelDelegate: AnyObject {
    func fetchData()
    func openSetupToDo(with item: ToDoItem?)
    func saveTask(item: ToDoItem)
    func deleteTask(id: String)
    func updateToDoList()
}
