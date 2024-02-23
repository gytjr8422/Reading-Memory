//
//  MemoryCategory.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/23/24.
//

import Foundation

enum MemoryCategory: Int, CaseIterable, Identifiable {
    case sentence
    case word
    case thought
    
    var title: String {
        switch self {
        case .sentence: return "문장"
        case .word: return "단어"
        case .thought: return "갈무리"
        }
    }
    
    var id: Int { return self.rawValue }
}
