//
//  Word.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/5/24.
//

import Foundation
import RealmSwift

class Word: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var word: String
    @Persisted var meaning: String
    @Persisted var sentence: String
    @Persisted var page: String
    @Persisted var liked: Bool
    
    @Persisted var addDate: Date
    @Persisted var editDate: Date
    
    override class func primaryKey() -> String? {
        "id"
    }
}
