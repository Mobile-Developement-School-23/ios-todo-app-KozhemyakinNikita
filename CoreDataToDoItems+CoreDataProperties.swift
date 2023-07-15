import Foundation
import CoreData


extension CoreDataToDoItems {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataToDoItems> {
        return NSFetchRequest<CoreDataToDoItems>(entityName: "CoreDataToDoItems")
    }

    @NSManaged public var created: Date?
    @NSManaged public var changed: Date?
    @NSManaged public var isDone: Bool
    @NSManaged public var importance: String?
    @NSManaged public var deadline: Date?
    @NSManaged public var text: String?
    @NSManaged public var id: String?

}

extension CoreDataToDoItems : Identifiable {

}
