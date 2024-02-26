//
//  DictionaryResult.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/26/24.
//

import Foundation

struct DictionaryResult: Codable {
    let channel: Channel
}

struct Channel: Codable {
    let link: String
    let item: [WordItem]
}

struct WordItem: Codable, Hashable {
    let word: String
    let sense: [Sense]
}

struct Sense: Codable, Hashable {
    let cat: String?
    let definition: String
    let link: String
    let origin: String?
}

extension WordItem {
    static let dummyItems = WordItem(
        word: "소택-지",
        sense: [Sense.dummySense]
    )
}

extension Sense {
    static let dummySense = Sense(
        cat: nil,
        definition: "늪과 연못으로 둘러싸인 습한 땅.",
        link: "http://opendict.korean.go.kr/dictionary/view?sense_no=536599",
        origin: "沼澤地"
    )
}
