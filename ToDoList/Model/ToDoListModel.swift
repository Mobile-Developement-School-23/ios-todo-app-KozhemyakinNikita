//
//  ToDoListModel.swift
//  ToDoList
//
//  Created by Nik Kozhemyakin on 30.06.2023.
//

import UIKit

enum IsHiddenItem {
    case showAllItems
    case hideCompletedItems
}

class ToDoListModel: UIViewController {
    var fileCache = FileCache()
    var fileName = "TodoCache"
    weak var listViewController: ToDoListViewController?
    var isDirty = false

    var toDoItems: [String: ToDoItem] = [:]
    public private(set) var status: IsHiddenItem = IsHiddenItem.hideCompletedItems

    init(fileName: String = "TodoCache", fileCache: FileCache = FileCache()) {
        super.init(nibName: nil, bundle: nil)
        self.fileName = fileName
        self.fileCache = fileCache
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ToDoListModel: ToDoListModelDelegate {

    func fetchData() {
        do {
            try fileCache.loadFromFile(from: "TodoCache")
        } catch {
            print("Error: fetchData()")
        }
    }

    func openSetupToDo(with item: ToDoItem? = nil) {
        let newNavViewController = UINavigationController(rootViewController: ToDoItemController())
        newNavViewController.modalTransitionStyle = .coverVertical
        newNavViewController.modalPresentationStyle = .formSheet
        listViewController?.present(newNavViewController, animated: true)
    }

    func saveTask(item: ToDoItem) {
        do {
            self.fileCache.addItem(item)
            try self.fileCache.saveToFile(to: fileName)
            self.updateToDoList()
        } catch {
            print("Error: saveToDo()")
        }
    }

    func deleteTask(id: String) {
        do {
            self.fileCache.deleteItem(id)
            try self.fileCache.saveToFile(to: fileName)
            self.updateToDoList()
        } catch {
            print("Error: deleteToDo()")
        }
    }

    func deleteRow(at indexPath: IndexPath) {
        var todoItem = Array(toDoItems.values).sorted(by: { $0.created < $1.created })
        let id = todoItem[indexPath.row].id
        do {
            try self.fileCache.deleteItem(id)
            try self.fileCache.saveToFile(to: fileName)
            todoItem.remove(at: indexPath.row)

            self.listViewController?.tableView.deleteRows(at: [indexPath], with: .right)

        } catch {
            print("Error: deleteToDo()")
        }
    }

    func updateToDoList() {
        switch self.status {
        case IsHiddenItem.hideCompletedItems:
            self.toDoItems = self.fileCache.todoItems.filter( { !$0.value.isDone } )
        case IsHiddenItem.showAllItems:
            self.toDoItems = self.fileCache.todoItems
        }
        self.listViewController?.reloadData()
    }

    func changeIsHiddenStatus(to newStatus: IsHiddenItem) {
        self.status = newStatus
    }
}
