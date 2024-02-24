//
//  MemoryCell.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/12/24.
//

import RealmSwift
import SwiftUI

struct MemoryCell<T: Memory>: View {
    @ObservedResults(Book.self) private var savedBooks
    @Environment(\.colorScheme) private var colorScheme
    
    let anyMemory: T
    let category: MemoryCategory
    let route: Route
    
    private var bookTitle: String {
        switch category {
        case .sentence:
            if let sentence = anyMemory as? Sentence,
                let bookTitle = savedBooks.filter("isbn == %@", sentence.isbn).first?.title {
                return bookTitle
            }
        case .word:
            if let word = anyMemory as? Word,
               let bookTitle = savedBooks.filter("isbn == %@", word.isbn).first?.title {
                return bookTitle
            }
        case .thought:
            if let thought = anyMemory as? Thought,
               let bookTitle = savedBooks.filter("isbn == %@", thought.isbn).first?.title {
                return bookTitle
            }
        }
        return ""
    }
    
    var body: some View {
        VStack {
            switch category {
            case .sentence:
                if let sentence = anyMemory as? Sentence {
                    TextAlignment(text: sentence.sentence, textAlignmentStyle: .justified, font: .systemFont(ofSize: 15), width: UIScreen.main.bounds.width * 0.35, lineLimit: 5, isLineLimit: .constant(true))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            if route == .memoryRoute {
                                Text(bookTitle)
                                    .lineLimit(1)
                            }
                            Text(DateToString.toString(sentence.editDate))
                        }
                            .font(.caption)
                        
                        Spacer()
                        
                        Image(systemName: sentence.liked ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundStyle(.red)
                            .onTapGesture {
                                Book.likeMemory(memoryId: sentence.id, category: .sentence)
                            }
                    }
                }
            case .word:
                if let word = anyMemory as? Word {
                    VStack {
                        TextAlignment(text: word.word, textAlignmentStyle: .justified, font: .systemFont(ofSize: 15), width: UIScreen.main.bounds.width * 0.35, lineLimit: 5, isLineLimit: .constant(true))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Divider()
                            .background(colorScheme == .light ? Color(hexCode: "50586C") : Color(hexCode: "DCE2F0"))
                        TextAlignment(text: word.meaning, textAlignmentStyle: .justified, font: .systemFont(ofSize: 15), width: UIScreen.main.bounds.width * 0.35, lineLimit: 5, isLineLimit: .constant(true))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        HStack(alignment: .bottom) {
                            VStack(alignment:. leading) {
                                if route == .memoryRoute {
                                    Text(bookTitle)
                                        .lineLimit(1)
                                }
                                Text(DateToString.toString(word.editDate))
                            }
                            .font(.caption)
                            Spacer()
                            Image(systemName: word.liked ? "heart.fill" : "heart")
                                .font(.title3)
                                .foregroundStyle(.red)
                                .onTapGesture {
                                    Book.likeMemory(memoryId: word.id, category: .word)
                                }
                        }
                    }
                }
            case .thought:
                if let thought = anyMemory as? Thought {
                    TextAlignment(text: thought.thought, textAlignmentStyle: .justified, font: .systemFont(ofSize: 15), width: UIScreen.main.bounds.width * 0.35, lineLimit: 5, isLineLimit: .constant(true))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            if route == .memoryRoute {
                                Text(bookTitle)
                                    .lineLimit(1)
                            }
                            Text(DateToString.toString(thought.editDate))
                        }
                        .font(.caption)
                        Spacer()
                        Image(systemName: thought.liked ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundStyle(.red)
                            .onTapGesture {
                                Book.likeMemory(memoryId: thought.id, category: .thought)
                            }
                    }
                    
                }
            }
        }
        .padding(15)
        .frame(width: UIScreen.main.bounds.width * 0.43, height: UIScreen.main.bounds.width * 0.45)
        .background(Color(hexCode: "50586C"))
        .clipped()
        .overlay {
            RoundedRectangle(cornerRadius: 7)
                .stroke(lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .foregroundStyle(colorScheme == .light ? Color(hexCode: "50586C") : Color(hexCode: "DCE2F0"))
    }
}

#Preview {
    MemoryCell(
        anyMemory: Sentence(value: [
        "sentence": "Hello Sentence",
        "idea": "My Idea",
        "addDate": Date(),
        "editDate": Date()
    ]),
        category: .sentence,
        route: .libraryRoute
    )
}
