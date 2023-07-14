//
//  CoreDataToDoItems+CoreDataClass.swift
//  ToDoList
//
//  Created by Nik Kozhemyakin on 14.07.2023.
//
//

import Foundation
import CoreData

@objc(CoreDataToDoItems)
public class CoreDataToDoItems: NSManagedObject {

}

extension CoreDataToDoItems {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataToDoItems> {
        return NSFetchRequest<CoreDataToDoItems>(entityName: "CoreDataToDoItems")
    }
    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var importance: NSObject?
    



}

extension CoreDataToDoItems : Identifiable {

}
