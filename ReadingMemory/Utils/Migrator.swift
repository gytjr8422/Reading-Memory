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
        
        let config = Realm.Configuration(schemaVersion: 15) { migration, oldSchemaVersion in
            if oldSchemaVersion < 14 {
                // add new fields
                migration.enumerateObjects(ofType: Book.className()) { _, newObject in
                    newObject!["stars"] = 0
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
