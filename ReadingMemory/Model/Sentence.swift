//
//  Sentence.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/5/24.
//

import Foundation
import RealmSwift

protocol Memory {
    var id: ObjectId { get }
    var addDate: Date { get set }
    var editDate: Date { get set }
}

final class Sentence: Object, Identifiable, Memory {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var sentence: String
    @Persisted var idea: String
    @Persisted var page: String
    @Persisted var liked: Bool
    
    @Persisted var addDate: Date
    @Persisted var editDate: Date
    
    @Persisted var isbn: String
    
    override class func primaryKey() -> String? {
        "id"
    }
}
