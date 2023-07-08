import Foundation
import CocoaLumberjackSwift

protocol NetworkingService {
    func getList() async throws -> [ToDoItem]
    func patchList(with toDoItem: [ToDoItem]) async throws -> [ToDoItem]
    func getItem(by id: String) async throws -> ToDoItem
    func postItem(with toDoItem: ToDoItem) async throws -> ToDoItem
    func putItem(with toDoItem: ToDoItem) async throws -> ToDoItem
    func deleteItem(by id: String) async throws -> ToDoItem
}

class DefaultNetworkingService/*: NetworkingService*/ {
    private let token = "symmetric"
    private let userName = "Kozhemjakin_N"
    private var revision: Int = 0

    let url = URL(string: "https://beta.mrdekk.ru/todobackend")

    /*
        func getList() async throws -> [ToDoItem] {
            <#code#>
        }
        
        func patchList(with toDoItem: [ToDoItem]) async throws -> [ToDoItem] {
            <#code#>
        }
        
        func getItem(by id: String) async throws -> ToDoItem {
            <#code#>
        }
        
        func postItem(with toDoItem: ToDoItem) async throws -> ToDoItem {
            <#code#>
        }
        
        func putItem(with toDoItem: ToDoItem) async throws -> ToDoItem {
            <#code#>
        }
        
        func deleteItem(by id: String) async throws -> ToDoItem {
            <#code#>
        }
    */

}
