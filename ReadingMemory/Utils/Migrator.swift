//
//  Migrator.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/6/24.
//

import Foundation
import RealmSwift

class Migrator {
    
    init() {
        updateSchema()
    }
    
    func updateSchema() {
        
        let config = Realm.Configuration(schemaVersion: 8) { migration, oldSchemaVersion in
            if oldSchemaVersion < 7 {
                // add new fields
                migration.enumerateObjects(ofType: Book.className()) { _, newObject in
//                    newObject!["isbn"] = ""
                }
            }
            
//            if oldSchemaVersion < 2 {
//                migration.enumerateObjects(ofType: ShoppingItem.className()) { _, newObject in
//                    newObject!["category"] = ""
//                }
//            }
            
            
        }
        
        Realm.Configuration.defaultConfiguration = config
        let _ = try! Realm()
        
    }
    
}
