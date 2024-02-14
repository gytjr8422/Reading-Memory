//
//  MemoryEditorView.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/12/24.
//

import SwiftUI

struct MemoryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                TextMaster(text: $text, isFocused: $isFocused, maxLine: 10, fontSize: 12)
                    .background(Color(hexCode: "F0EDCC"))

//                TextEditor(text: $text)
//                    .background(Color(hexCode: "F0EDCC"))
//                    .overlay(content: {
//                        
//                    })
//                    .cornerRadius(8)
//                    
//                    .padding()
//                Rectangle()
//                    
//                TextEditor(text: $text)
//                    .background(Color(hexCode: "F0EDCC"))
            }
//            .padding()
            .background(Color(hexCode: "F0EDCC"))
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("닫기")
                    }

                }
            })
        }
        
    }
}

#Preview {
    MemoryEditorView()
}
