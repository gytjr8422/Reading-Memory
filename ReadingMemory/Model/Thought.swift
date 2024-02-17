//
//  Thought.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/14/24.
//

import Foundation
import RealmSwift

class Thought: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var thought: String
    @Persisted var page: String
    
    @Persisted var addDate: Date
    @Persisted var editDate: Date
    
    override class func primaryKey() -> String? {
        "id"
    }
}
