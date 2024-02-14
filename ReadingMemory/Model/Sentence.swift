//
//  Sentence.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/5/24.
//

import Foundation
import RealmSwift

class Sentence: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var memo: String
    @Persisted var idea: String
    @Persisted var date: Date
    
    override class func primaryKey() -> String? {
        "id"
    }
}
