//
//  MemoryViewModel.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/22/24.
//

import SwiftUI
import RealmSwift

class MemoryViewModel: ObservableObject {
    
    @ObservedResults(Sentence.self) private var savedSentences
    @ObservedResults(Word.self) private var savedWords
    @ObservedResults(Thought.self) private var savedThoughts
    
    @Published var sentences: [Sentence] = []
    @Published var words: [Word] = []
    @Published var thoughts: [Thought] = []
    
    func searchMemory(searchText: String) {
        if searchText.isEmpty {
            sentences = Array(savedSentences)
        } else {
            sentences = savedSentences.filter { $0.sentence.lowercased().contains(searchText.lowercased()) }
        }
    }
}
