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

class ToDoListModel {
    var fileCache = FileCache()
    var fileName = "TodoCache"
    weak var listViewController: ToDoListViewController?
//    let networkingService: NetworkingService
//    private let networkingService = DefaultNetworkingService.shared
    var isDirty = false

    var toDoItems: [ToDoItem] = []
    public private(set) var status: IsHiddenItem = IsHiddenItem.hideCompletedItems

//    init(fileName: String = "TodoCache", fileCache: FileCache = FileCache(), dataProvider: NetworkingService = DefaultNetworkingService()) {
////        super.init(nibName: nil, bundle: nil)
//        self.fileName = fileName
//        self.fileCache = fileCache
//        self.networkingService = dataProvider
//        Task.detached { [weak self] in
//            do {
//                try await self?.fetchTodoItems()
//            } catch {
//                print("Error load data", error)
//            }
//        }
//    }
    
//    init() {
//        Task.detached { [weak self] in
//            do {
//              print("loading loadin")
//                try await self?.fetchTodoItems()
//            } catch {
//                print("Error load data", error)
//            }
//        }
//      }

//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
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
//        var todoItem = Array(toDoItems.values).sorted(by: { $0.created < $1.created })
        toDoItems.sort(by: { $0.created < $1.created })
        let id = toDoItems[indexPath.row].id
        do {
            try self.fileCache.deleteItem(id)
            try self.fileCache.saveToFile(to: fileName)
            toDoItems.remove(at: indexPath.row)

            self.listViewController?.tableView.deleteRows(at: [indexPath], with: .right)

        } catch {
            print("Error: deleteToDo()")
        }
    }

    func updateToDoList() {
        switch self.status {
        case IsHiddenItem.hideCompletedItems:
//            self.toDoItems = self.fileCache.todoItems.filter( { !$0.value.isDone } )
            self.toDoItems = self.toDoItems.filter { !$0.isDone }
        case IsHiddenItem.showAllItems:
            self.toDoItems = Array(self.toDoItems)
        }
        self.listViewController?.reloadData()
    }

    func changeIsHiddenStatus(to newStatus: IsHiddenItem) {
        self.status = newStatus
    }
}

//MARK: - Network methods

//extension ToDoListModel: @unchecked Sendable {
//    func fetchTodoItems() async throws {
//        Task.detached { [weak self] in
//            guard let self = self else { return }
//            do {
//                let items = try await self.networkingService.getList()
//
//                DispatchQueue.main.async {
//                    self.toDoItems = items
////                    for item in items {
////                        self.fileCache.addItem(item)
////                    }
//
////                    print(items)
////                    self.uncompletedTodoItems = self.toDoItems.filter { !$0.isDone }
////                    self.completedTasksCount = self.toDoItems.filter { $0.isDone }.count
////                    self.isLoading = false
//                }
////                try self.fileCache.saveToFile(to: self.fileName)
////                listModel.updateToDoList()
//                await listViewController?.reloadData()
//
//
//            } catch let error {
////                DispatchQueue.main.async {
////                    self.isLoading = false
////                    if let error = error as? APIErrors {
////                        try await self.fileCache.loadFromFile(from: "TodoCache")
//////                        self.errorHandler?(error)
////                    } else {
//////                        self.loadItems()
////                       try await self.fileCache.loadFromFile(from: "TodoCache")
////                    }
////                }
//            }
//        }
//    }
//
//    private func syncDataWithServer() async throws {
//        guard isDirty else { return }
////        isLoading = true
//        do {
//            let networkItems = try await networkingService.getList()
//            let todoList = try await networkingService.patchList(networkItems)
//
//            DispatchQueue.main.async { [weak self] in
//                self?.toDoItems = todoList
//                self?.isDirty = false
////                self?.isLoading = false
//            }
//
//        } catch {
//            print("Failed to sync data with server")
//        }
//    }
//
//    //...//
//
//    func addNewItem(_ item: ToDoItem) async throws {
//        Task.detached { [weak self] in
//            guard let self = self else { return }
////            isLoading = true
//            do {
//                let addedItem = try await self.networkingService.postItem(item)
//                DispatchQueue.main.async {
//                    self.saveTask(item: addedItem)
////                    self.isLoading = false
//                }
//
//                if isDirty {
//                    try await syncDataWithServer()
//                }
//            } catch {
//                DispatchQueue.main.async {
////                    self.isLoading = false
//                    self.isDirty = true
//                    self.saveTask(item: item)
//                }
//            }
//        }
//    }
//}
