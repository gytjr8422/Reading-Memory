//
//  BookViewModel.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/18/24.
//

//import Foundation
//import RealmSwift

//class BookViewModel: ObservableObject {
//    @Published var realmBook: Book?
//    @Published var naverBook: BookDocument?
//    
//    init(book: Book? = nil, naverBook: BookDocument? = nil) {
//        self.realmBook = book
//        self.naverBook = naverBook
//    }
//    
//    var book: Any? {
//        if let book = realmBook {
//            return book
//        } else if let naverBook = naverBook {
//            return naverBook
//        }
//        return nil
//    }
//    
//    var authors: List<String> {
//        if let book = realmBook {
//            return book.authors
//        } else if let naverBook = naverBook {
//            return naverBook.authors
//        }
//        return List<String>()
//    }
//    
//    var contents: String {
//        if let book = realmBook {
//            return book.contents
//        } else if let naverBook = naverBook {
//            return naverBook.contents
//        }
//        return ""
//    }
//    var datetime: String {
//        if let book = realmBook {
//            return book.datetime
//        } else if let naverBook = naverBook {
//            return naverBook.datetime
//        }
//        return ""
//    }
//    
//    var isbn: String {
//        if let book = realmBook {
//            return book.isbn
//        } else if let naverBook = naverBook {
//            return naverBook.isbn
//        }
//        return ""
//    }
//    
//    var price: Int {
//        if let book = realmBook {
//            return book.price
//        } else if let naverBook = naverBook {
//            return naverBook.price
//        }
//        return 0
//    }
//    
//    var publisher: String {
//        if let book = realmBook {
//            return book.publisher
//        } else if let naverBook = naverBook {
//            return naverBook.publisher
//        }
//        return ""
//    }
//    
//    var salePrice: Int {
//        if let naverBook = naverBook {
//            return naverBook.salePrice
//        }
//        return 0
//    }
//    
//    var status: String {
//        if let naverBook = naverBook {
//            return naverBook.datetime
//        }
//        return ""
//    }
//    
//    var thumbnail: String {
//        if let book = realmBook {
//            return book.thumbnail
//        } else if let naverBook = naverBook {
//            return naverBook.thumbnail
//        }
//        return ""
//    }
//    
//    var title: String {
//        if let book = realmBook {
//            return book.title
//        } else if let naverBook = naverBook {
//            return naverBook.title
//        }
//        return ""
//    }
//    var translators: List<String> {
//        if let book = realmBook {
//            return book.translators
//        } else if let naverBook = naverBook {
//            return naverBook.translators
//        }
//        return List<String>()
//    }
//    
//    var url: String {
//        if let book = realmBook {
//            return book.url
//        } else if let naverBook = naverBook {
//            return naverBook.url
//        }
//        return ""
//    }
//    
//    var like: Bool? {
//        if let book = realmBook {
//            return book.like
//        } else if let naverBook = naverBook {
//            return naverBook.like
//        }
//        return false
//    }
//    
//    var reading: Bool? {
//        if let book = realmBook {
//            return book.reading
//        } else if let naverBook = naverBook {
//            return naverBook.reading
//        }
//        return false
//    }
//    
//    var finished: Bool? {
//        if let book = realmBook {
//            return book.finished
//        } else if let naverBook = naverBook {
//            return naverBook.finished
//        }
//        return false
//    }
//    
//    var memos: List<Sentence> {
//        if let book = realmBook {
//            return book.memos
//        }
//        return List<Memo>()
//    }
//    
//    var words: List<Word> {
//        if let book = realmBook {
//            return book.words
//        }
//        return List<Word>()
//    }
//}

