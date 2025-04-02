//
//  Item+CoreDataProperties.swift
//  Stash House
//
//  Created by Justin Trubela on 4/2/25.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var barcode: String?
    @NSManaged public var category: String?
    @NSManaged public var id: UUID?
    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var title: String?

}

extension Item : Identifiable {

}
