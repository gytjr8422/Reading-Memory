//
//  DictionaryCell.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/26/24.
//

import SwiftUI

struct DictionaryCell: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let item: WordItem
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .bottom) {
                Text(item.word)
                if let sense = item.sense.first {
                    if let origin = sense.origin {
                        Text("(\(origin))")
                    }
                    if let category = sense.cat {
                        Text(category)
                            .font(.caption)
                            .padding(2)
                            .background(.white)
                            .foregroundStyle(.black)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                    }
                }
            }
            
            Divider()
                .background(.white)
            
            if let sense = item.sense.first {
                Text(sense.definition)
                    .lineLimit(1)
            }
        }
        .padding(15)
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
