//
//  Category+CoreDataProperties.swift
//  Stash House
//
//  Created by Justin Trubela on 4/2/25.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var name: String?
    @NSManaged public var id: UUID?
    @NSManaged public var items: Item?

}

extension Category : Identifiable {

}
