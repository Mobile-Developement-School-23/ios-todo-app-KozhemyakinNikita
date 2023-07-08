import Foundation
import UIKit
import CocoaLumberjack
import CocoaLumberjackSwift

enum Importance: String {
    case important
    case common
    case unimpurtant
}

private enum Keys {
     static let kId = "id"
     static let kText = "text"
     static let kImportance = "importance"
     static let kDeadline = "deadline"
     static let kIsDone = "done"
     static let kCreated = "created_at"
     static let kChanged = "changed_at"
 }

struct ToDoItem {
    let id: String
    let text: String
    let deadline: Date?
    let importance: Importance

    let isDone: Bool
    let created: Date
    let changed: Date?

    init(
        id: String = UUID().uuidString,
        text: String,
        deadline: Date?,
        importance: Importance,
        isDone: Bool,
        created: Date,
        changed: Date?
    ) {
        self.id = id
        self.text = text
        self.deadline = deadline
        self.importance = importance
        self.isDone = isDone
        self.created = created
        self.changed = changed
    }

}

extension ToDoItem {
    static func parse(json: Any) -> ToDoItem? {
        guard let jsn = json as? [String: Any] else {
            return nil
        }

        guard let id = jsn[Keys.kId] as? String,
              let text = jsn[Keys.kText] as? String,
              let isDone = jsn[Keys.kIsDone] as? Bool,
              let createdTI = jsn[Keys.kCreated] as? TimeInterval
        else {
            return nil
        }

        let importance = (jsn[Keys.kImportance] as? String).flatMap(Importance.init(rawValue:)) ?? .common

        let created = Date(timeIntervalSince1970: createdTI)

        let deadlineTI = jsn[Keys.kDeadline] as? TimeInterval
        let deadline = deadlineTI.map { Date(timeIntervalSince1970: $0) }

        let changedTI = jsn[Keys.kChanged] as? TimeInterval
        let changed = changedTI.map { Date(timeIntervalSince1970: $0) }

        return ToDoItem(
            id: id,
            text: text,
            deadline: deadline,
            importance: importance,
            isDone: isDone,
            created: created,
            changed: changed
        )
    }
    var json: Any {
        var dict: [String: Any] = [
            Keys.kId: id,
            Keys.kText: text,
            Keys.kIsDone: isDone,
            Keys.kCreated: created.timeIntervalSince1970,
        ]
        if let deadline = deadline {
            dict[Keys.kDeadline] = deadline.timeIntervalSince1970
        }
        if let changed = changed {
            dict[Keys.kChanged] = changed.timeIntervalSince1970
        }
        if importance != .common {
            dict[Keys.kImportance] = importance.rawValue
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            return json
        } catch {
            print("Error serializing JSON: \(error)")
        }

        return dict
    }
}

final class FileCache {
    private let logger: DDLog = {
        let logger = DDLog()
        DDLog.add(DDOSLogger.sharedInstance) // Добавление консольного логгера
        return logger
    }()

    private(set) var todoItems: [String: ToDoItem] = [:]
    var isDirty: Bool {
        get { UserDefaults.standard.bool(forKey: "isDirty") }
        set { UserDefaults.standard.set(newValue, forKey: "isDirty") }
    }

    func addItem(_ item: ToDoItem) -> ToDoItem? {
        let itm = todoItems[item.id]
        todoItems[item.id] = item
        DDLogInfo("Item successfully added to json")
        return itm
    }

    func deleteItem(_ id: String) -> ToDoItem? {
        let item = todoItems[id]
        todoItems[id] = nil
        DDLogInfo("Item successfully deleted from json")
        return item
    }

    func saveToFile(to file: String) throws {
        guard let cacheUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let serializedItems = todoItems.values.map { $0.json }
        let path = cacheUrl.appendingPathComponent("\(file).json")
        let data = try JSONSerialization.data(withJSONObject: serializedItems, options: [])
        try data.write(to: path)

        DDLogInfo("File successfully saved \(file).json")

    }

    func loadFromFile(from file: String) throws {
        guard let cacheUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let path = cacheUrl.appendingPathComponent("\(file).json")
        let data = try Data(contentsOf: path)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let jsonArray = json as? [Any] else {
            return
        }
        let deserializedItems = jsonArray.compactMap { ToDoItem.parse(json: $0) }
        self.todoItems = Dictionary(uniqueKeysWithValues: deserializedItems.map { ($0.id, $0) })
        DDLogInfo("File successfully loaded \(file).json")
    }
    func updateItem(_ id: String, withUpdatedIsDone isDone: Bool) {
        guard var item = todoItems[id] else {
            return
        }
        item = ToDoItem(
            id: item.id,
            text: item.text,
            deadline: item.deadline,
            importance: item.importance,
            isDone: isDone,
            created: item.created,
            changed: item.changed
        )
        todoItems[id] = item
        DDLogInfo("Item successfully updated in json")
    }
}
