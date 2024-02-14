//
//  SearchResult.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/13/24.
//

import Foundation
import RealmSwift

struct SearchResult: Codable {
    let documents: [BookDocument]
    let meta: Meta
}

struct BookDocument: Codable, Hashable {
    
    var authors: [String]
    var contents: String
    var datetime: String
    var isbn: String
    var price: Int
    var publisher: String
    var salePrice: Int
    var status: String
    var thumbnail: String
    var title: String
    var translators: [String]
    var url: String
    
    enum CodingKeys: String, CodingKey {
        case authors, contents, datetime, isbn, price, publisher, status, thumbnail, title, translators, url
        case salePrice = "sale_price"
    }
}

struct Meta: Codable {
    
    var isEnd: Bool
    
    enum CodingKeys: String, CodingKey {
        case isEnd = "is_end"
    }

}

struct NaverResult: Codable {
    let items: [Item]
}

struct Item: Codable {
    let title: String
    let link: String
    let image: String
    let author: String
    let discount: String
    let publisher: String
    let pubdate: String
    let isbn: String
    let description: String
}

extension BookDocument {
    static let dummyDocument = BookDocument(
        authors: ["유발 하라리"],
        contents: "‘천재 사상가’(뉴욕타임스) 유발 하라리의 대표작 《사피엔스》. 이제 불황이라는 수식어가 전혀 어색하지 않은 국내 출판시장에서도 《사피엔스》는 인문교양 분야의 트렌드를 주도하며 2023년 1월 기준 ‘200쇄 발행·115만부 판매’라는 놀라운 기록을 거두고 있다. 인류 역사와 미래를 종횡무진 가로지르는 《사피엔스》의 통찰은 불확실하고 복잡한 세계를 이해하고 대비하는 데 반드시 필요하다. 책 서두에는 2011년 원서 출간 이후 10년을 돌아보고 위기",
        datetime: "2020.01.01",
        isbn: "8934972467 9788934972464",
        price: 26000,
        publisher: "김영사",
        salePrice: 24000,
        status: "",
        thumbnail: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F521598%3Ftimestamp%3D20240105155432",
        title: "사피엔스",
        translators: ["Translator1", "Translator2"],
        url: "https://search.daum.net/search?w=bookpage&bookId=521598&q=%EC%82%AC%ED%94%BC%EC%97%94%EC%8A%A4"
    )
}
