import Foundation
import UIKit
import CoreData

public final class CoreDataManager {
    static let shared = CoreDataManager()
    var todoItems: [String: ToDoItem] = [:]
    private init() {}
    let fileCache = FileCache()
    
    var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate   //change to safety
    }
    
    var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    //MARK: - CRUD
    
    func loadCoreData() -> [ToDoItem] {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<CoreDataToDoItems> = CoreDataToDoItems.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            for task in items {
                let todoItem = parseCoreData(todoItem: task)
                todoItems[todoItem.id] = todoItem
            }
            return items.map { item in
                ToDoItem(
                    id: item.id!,
                    text: item.text!,
                    deadline: item.deadline,
                    importance : Importance(rawValue: item.importance!) ?? .common,
                    isDone: item.isDone,
                    created: item.created!,
                    changed: item.changed
                    //lastUpdatedBy: ""
                )
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func insertCoreData(todoItem: ToDoItem) {
        let context = CoreDataManager.shared.context
        let entity = CoreDataToDoItems.entity()
        let task = CoreDataToDoItems(entity: entity, insertInto: context)
        task.id = todoItem.id
        task.text = todoItem.text
        task.deadline = todoItem.deadline
        task.importance = todoItem.importance.rawValue
        task.isDone = todoItem.isDone
        task.created = todoItem.created
        task.changed = todoItem.changed
        appDelegate.saveContext()
        
        print("\nCore data - successful adding task")
    }
    
    func updateCoreData(todoItem: ToDoItem) {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<CoreDataToDoItems> = CoreDataToDoItems.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", todoItem.id)
        do {
            let items = try context.fetch(fetchRequest)
            if items.count != 0 {
                context.delete(items[0])
                try context.save()
                insertCoreData(todoItem: todoItem)
            }
            print("\nCore data - successful updating task")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func deleteCoreData(todoItem: ToDoItem) {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<CoreDataToDoItems> = CoreDataToDoItems.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", todoItem.id)
        
        let items = try? context.fetch(fetchRequest)
        guard let coreItem = items?.first else { return }
        
        appDelegate.persistentContainer.viewContext.delete(coreItem)
        appDelegate.saveContext()
        print("\nCore data - successful deleting task")
    }
    
    
    func parseCoreData(todoItem: CoreDataToDoItems) -> ToDoItem {
        guard
            let id = todoItem.id,
            let text = todoItem.text,
            let importance = todoItem.importance,
            let createDate = todoItem.created
        else {
            fatalError("\nError of parsing coreData")
        }
        
        let item = ToDoItem.parseItems(
            id: id,
            text: text,
            deadline: todoItem.deadline,
            importance: importance,
            isDone: todoItem.isDone,
            created: createDate,
            changed: todoItem.changed)
        guard let item else {
            fatalError("\nError of parsing coreData")
        }
        return item
    }
}
