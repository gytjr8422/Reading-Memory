//
//  DateToString.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/20/24.
//

import Foundation

class DateToString {
    static func toString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let stringDate = formatter.string(from: date)
        return stringDate
    }
}
