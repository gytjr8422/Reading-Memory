//
//  Word.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/5/24.
//

import Foundation
import RealmSwift

class Word: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var word: String
    @Persisted var sentence: String
    @Persisted var page: String
    
    override class func primaryKey() -> String? {
        "id"
    }
}
