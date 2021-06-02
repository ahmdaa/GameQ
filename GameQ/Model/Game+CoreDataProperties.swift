//
//  Game+CoreDataProperties.swift
//  
//
//  Created by Ahmed Abdalla on 12/12/20.
//
//

import Foundation
import CoreData


extension Game {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Game> {
        return NSFetchRequest<Game>(entityName: "Game")
    }

    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var slug: String?

}
