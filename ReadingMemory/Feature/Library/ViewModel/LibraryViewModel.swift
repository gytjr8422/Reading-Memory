//
//  LibraryViewModel.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/16/24.
//

import RealmSwift
import SwiftUI

final class LibraryViewModel: ObservableObject {
    
    func fetchFirstAndLatestInputDates(sentences: RealmSwift.List<Sentence>, words: RealmSwift.List<Word>, thoughts: RealmSwift.List<Thought>) -> (String, String) {
        
        var firstDate: String = ""
        var latestDate: String = ""
        
        let minAddDateSentences = sentences.map({ $0.addDate }).min()
        let minAddDateWords = words.map({ $0.addDate }).min()
        let minAddDateThoughts = thoughts.map({ $0.addDate }).min()

        let minAddDates = [minAddDateSentences, minAddDateWords, minAddDateThoughts].compactMap { $0 }
        if let minAddDate = minAddDates.min() {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 MM월 dd일"
            firstDate = formatter.string(from: minAddDate)
        } else {
            print("All arrays are empty.")
        }
        
        let maxEditDateSentences = sentences.map({ $0.editDate }).max()
        let maxEditDateWords = words.map({ $0.editDate }).max()
        let maxEditDateThoughts = thoughts.map({ $0.editDate }).max()

        let maxEditDates = [maxEditDateSentences, maxEditDateWords, maxEditDateThoughts].compactMap { $0 }
        if let maxEditDate = maxEditDates.max() {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 MM월 dd일"
            latestDate = formatter.string(from: maxEditDate)
        } else {
            print("All arrays are empty.")
        }

        
        return (firstDate, latestDate)
    }
    
    func latestEditDate(sentences: RealmSwift.List<Sentence>, words: RealmSwift.List<Word>, thoughts: RealmSwift.List<Thought>) -> Date {
        let maxEditDateSentences = sentences.map({ $0.editDate }).max()
        let maxEditDateWords = words.map({ $0.editDate }).max()
        let maxEditDateThoughts = thoughts.map({ $0.editDate }).max()

        let maxEditDates = [maxEditDateSentences, maxEditDateWords, maxEditDateThoughts].compactMap { $0 }
        
        return maxEditDates.max() ?? Date()
    }
}
