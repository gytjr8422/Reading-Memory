//
//  LibraryViewModel.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/16/24.
//

import RealmSwift
import SwiftUI

class LibraryViewModel: ObservableObject {
    
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
        
        let maxAddDateSentences = sentences.map({ $0.editDate }).max()
        let maxAddDateWords = words.map({ $0.editDate }).max()
        let maxAddDateThoughts = thoughts.map({ $0.editDate }).max()

        let maxAddDates = [maxAddDateSentences, maxAddDateWords, maxAddDateThoughts].compactMap { $0 }
        if let maxAddDate = maxAddDates.max() {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 MM월 dd일"
            latestDate = formatter.string(from: maxAddDate)
        } else {
            print("All arrays are empty.")
        }

        
        return (firstDate, latestDate)
    }
}
