//
//  Book.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/17/24.
//

import Foundation
import RealmSwift

final class Book: Object, Identifiable {
    
    @Persisted var authors: List<String>
    @Persisted var contents: String
    @Persisted var datetime: String
    @Persisted(primaryKey: true) var isbn: String
    @Persisted var price: Int
    @Persisted var publisher: String
    @Persisted var thumbnail: String
    @Persisted var title: String
    @Persisted var translators: List<String>
    @Persisted var url: String
    
    @Persisted var liked: Bool
    @Persisted var reading: Bool
    @Persisted var finished: Bool
    
    @Persisted var sentences = List<Sentence>()
    @Persisted var words = List<Word>()
    @Persisted var thoughts = List<Thought>()
    
    @Persisted var addDate: Date = Date()
    @Persisted var startDate: Date
    @Persisted var endDate: Date
    
    override class func primaryKey() -> String? {
        "isbn"
    }
}

extension Book {
    
    private static var realm = try! Realm()
    
    static func fetchAll() -> Results<Book> {
        realm.objects(Book.self)
    }
    
    // 여기부터
    static func addBook(_ naverBook: BookDocument, _ bookDescription: String, editCategory: EditList) {
        let book = Book(value: [
            "authors": naverBook.authors,
            "contents": bookDescription,
            "datetime": naverBook.datetime,
            "isbn": naverBook.isbn,
            "price": naverBook.price,
            "publisher": naverBook.publisher,
            "thumbnail": naverBook.thumbnail,
            "title": naverBook.title,
            "translators": naverBook.translators,
            "url": naverBook.url,
            "like": false,
            "reading": false,
            "finished": false,
            "addDate": Date()
        ])
        
        try! realm.write {
            realm.add(book)
            
            if let editingBook = realm.object(ofType: Book.self, forPrimaryKey: book.isbn) {
                switch editCategory {
                case .like:
                    editingBook.liked = editingBook.liked == false ? true : false
                case .reading:
                    editingBook.reading = editingBook.reading == false ? true : false
                case .finished:
                    editingBook.finished = editingBook.finished == false ? true : false
                case .memo:
                    break
                case .word:
                    break
                case .all:
                    break
                }
            }
        }
    }
    
    static func deleteBook(_ book: Book) {
        try! realm.write {
            realm.delete(book)
        }
    }
    
    static func deleteBooks(_ books: [Book]) {
        try! realm.write {
            for book in books {
                // Book 객체가 현재 사용 중인 Realm에 속하는지 확인
                if let bookInRealm = realm.object(ofType: Book.self, forPrimaryKey: book.isbn) {
                    // 현재 Realm에 속하는 경우 삭제
                    deleteBookMemories(Array(book.sentences))
                    deleteBookMemories(Array(book.words))
                    deleteBookMemories(Array(book.thoughts))
                    realm.delete(bookInRealm)
                } else {
                    // 현재 Realm에 속하지 않는 경우 처리할 작업 수행
                    print("해당 책이 메모리에 존재하지 않습니다.")
                }
            }
        }
    }
    
    static func editBook(_ book: Book, editCategory: EditList) {
        if let editingBook = realm.object(ofType: Book.self, forPrimaryKey: book.isbn) {
            try! realm.write {
                switch editCategory {
                case .like:
                    editingBook.liked = editingBook.liked == false ? true : false
                case .reading:
                    editingBook.reading = editingBook.reading == false ? true : false
                case .finished:
                    editingBook.finished = editingBook.finished == false ? true : false
                default:
                    break
                }
            }
        }
    }
    
    static func addMemory(_ book: Book?, category: MemoryCategory, firstText: String, secondText: String?, thirdText: String?, pageText: String?) {
        guard let book else { return }
        if let editingBook = realm.object(ofType: Book.self, forPrimaryKey: book.isbn) {
            var sentence: Sentence = Sentence()
            var word: Word = Word()
            var thought: Thought = Thought()
            
            switch category {
            case .sentence:
                sentence = Sentence(value: [
                    "sentence": firstText,
                    "idea": secondText == nil ? "" : secondText!,
                    "page": pageText == nil ? "" : pageText!,
                    "liked": false,
                    "addDate": Date(),
                    "isbn": book.isbn
                ])
            case .word:
                word = Word(value: [
                    "word": firstText,
                    "meaning": secondText == nil ? "" : secondText!,
                    "sentence": thirdText == nil ? "" : thirdText!,
                    "page": pageText == nil ? "" : pageText!,
                    "liked": false,
                    "addDate": Date(),
                    "isbn": book.isbn
                ])
            case .thought:
                thought = Thought(value: [
                    "thought": firstText,
                    "page": pageText == nil ? "" : pageText!,
                    "liked": false,
                    "addDate": Date(),
                    "isbn": book.isbn
                ])
            }
            
            try! realm.write {
                switch category {
                case .sentence:
                    editingBook.sentences.append(sentence)
                case .word:
                    editingBook.words.append(word)
                case .thought:
                    editingBook.thoughts.append(thought)
                }
            }
        }
    }
    
    static func editMemory(_ book: Book?, memoryId: ObjectId?, category: MemoryCategory, firstText: String, secondText: String?, thirdText: String?, pageText: String?) {
        @ObservedResults(Sentence.self) var sentences
        @ObservedResults(Word.self) var words
        @ObservedResults(Thought.self) var thoughts
        
        switch category {
        case .sentence:
            if let sentenceToEdit = sentences.first(where: { $0.id == memoryId }) {
                try! realm.write {
                    sentenceToEdit.sentence = firstText
                    sentenceToEdit.idea = thirdText == nil ? "" : thirdText!
                    sentenceToEdit.page = pageText == nil ? "" : pageText!
                    sentenceToEdit.editDate = Date()
                }
            }
        case .word:
            if let wordToEdit = words.first(where: { $0.id == memoryId }) {
                try! realm.write {
                    wordToEdit.word = firstText
                    wordToEdit.meaning = secondText == nil ? "" : secondText!
                    wordToEdit.sentence = thirdText == nil ? "" : thirdText!
                    wordToEdit.page = pageText == nil ? "" : pageText!
                    wordToEdit.editDate = Date()
                }
            }
        case .thought:
            if let thoughtToEdit = thoughts.first(where: { $0.id == memoryId }) {
                try! realm.write {
                    thoughtToEdit.thought = firstText
                    thoughtToEdit.page = pageText == nil ? "" : pageText!
                    thoughtToEdit.editDate = Date()
                }
            }
        }
    }
    
    static func likeMemory(memoryId: ObjectId, category: MemoryCategory) {
            switch category {
            case .sentence:
                if let sentenceToEdit = realm.object(ofType: Sentence.self, forPrimaryKey: memoryId) {
                    try! realm.write {
                        sentenceToEdit.liked.toggle()
                    }
                }
            case .word:
                if let wordToEdit = realm.object(ofType: Word.self, forPrimaryKey: memoryId) {
                    try! realm.write {
                        wordToEdit.liked.toggle()
                    }
                }
            case .thought:
                if let thoughtToEdit = realm.object(ofType: Thought.self, forPrimaryKey: memoryId) {
                    try! realm.write {
                        thoughtToEdit.liked.toggle()
                    }
                }
            }
    }
    
    static func deleteMemories(_ memories: [Memory]) {
        for memory in memories {
            if let sentence = memory as? Sentence, let sentenceObject = realm.object(ofType: Sentence.self, forPrimaryKey: sentence.id) {
                try! realm.write {
                    realm.delete(sentenceObject)
                }
            } else if let word = memory as? Word, let wordObject = realm.object(ofType: Word.self, forPrimaryKey: word.id) {
                try! realm.write {
                    realm.delete(wordObject)
                }
            } else if let thought = memory as? Thought, let thoughtObject = realm.object(ofType: Thought.self, forPrimaryKey: thought.id) {
                try! realm.write {
                    realm.delete(thoughtObject)
                }
            }
        }
    }
    
    static func deleteBookMemories(_ memories: [Memory]) {
        for memory in memories {
            if let sentence = memory as? Sentence, let sentenceObject = realm.object(ofType: Sentence.self, forPrimaryKey: sentence.id) {
                realm.delete(sentenceObject)
            } else if let word = memory as? Word, let wordObject = realm.object(ofType: Word.self, forPrimaryKey: word.id) {
                realm.delete(wordObject)
            } else if let thought = memory as? Thought, let thoughtObject = realm.object(ofType: Thought.self, forPrimaryKey: thought.id) {
                realm.delete(thoughtObject)
            }
        }
    }
    
    static func findSavedBook(_ isbn: String) -> Book? {
        realm.object(ofType: Book.self, forPrimaryKey: isbn)
    }
    
    
    static func isSavedBook(isbn: String) -> Bool {
        if let _ = realm.object(ofType: Book.self, forPrimaryKey: isbn) {
            return true
        }
        return false
    }
}

extension Book {
    static let dummyBook: Book = {
        var dummyAuthors = List<String>()
        dummyAuthors.append(objectsIn: ["유발 하라리"])
        let dummyContents = "‘천재 사상가’(뉴욕타임스) 유발 하라리의 대표작 《사피엔스》. 이제 불황이라는 수식어가 전혀 어색하지 않은 국내 출판시장에서도 《사피엔스》는 인문교양 분야의 트렌드를 주도하며 2023년 1월 기준 ‘200쇄 발행·115만부 판매’라는 놀라운 기록을 거두고 있다. 인류 역사와 미래를 종횡무진 가로지르는 《사피엔스》의 통찰은 불확실하고 복잡한 세계를 이해하고 대비하는 데 반드시 필요하다. 책 서두에는 2011년 원서 출간 이후 10년을 돌아보고 위기"
        let dummyDatetime = "2020.01.01"
        let dummyIsbn = "8934972467 9788934972464"
        let dummyPrice = 26000
        let dummyPublisher = "김영사"
        let dummyThumbnail = "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F521598%3Ftimestamp%3D20240105155432"
        let dummyTitle = "사피엔스"
        var dummyTranslators = List<String>()
        dummyTranslators.append(objectsIn: ["Translator1", "Translator2"])
        let dummyUrl = "https://search.daum.net/search?w=bookpage&bookId=521598&q=%EC%82%AC%ED%94%BC%EC%97%94%EC%8A%A4"
        let dummyLike = false
        let dummyReading = false
        let dummyFinished = true
        
        var sentences = List<Sentence>()
        let sentence = Sentence(value: [
            "sentence": "Hello Sentence",
            "idea": "My Idea",
            "addDate": Date(),
            "editDate": Date()
        ])
        sentences.append(sentence)
        
        var words = List<Word>()
        let word = Word(value: [
            "word": "Hello Word",
            "sentence": "Word Sentence"
        ])
        words.append(word)
        
        var thoughts = List<Thought>()
        let thought = Thought(value: [
            "thought": "My Thought"
        ])
        thoughts.append(thought)

        return Book(value: [
            "authors": dummyAuthors,
            "contents": dummyContents,
            "datetime": dummyDatetime,
            "isbn": dummyIsbn,
            "price": dummyPrice,
            "publisher": dummyPublisher,
            "thumbnail": dummyThumbnail,
            "title": dummyTitle,
            "translators": dummyTranslators,
            "url": dummyUrl,
            "like": dummyLike,
            "reading": dummyReading,
            "finished": dummyFinished
        ])
    }()
}

