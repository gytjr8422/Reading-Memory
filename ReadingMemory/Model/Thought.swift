//
//  Thought.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/14/24.
//

import Foundation
import RealmSwift

final class Thought: Object, Identifiable, Memory {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var thought: String
    @Persisted var page: String
    @Persisted var liked: Bool
    
    @Persisted var addDate: Date
    @Persisted var editDate: Date
    
    @Persisted var isbn: String
    
    override class func primaryKey() -> String? {
        "id"
    }
}
