//
//  RMTextField.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/12/24.
//

import SwiftUI

struct RMTextField: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @Binding var text: String
    /// 잘못된 입력값 여부
    let isWrongText: Bool
    /// Textfield 비활성화 여부
    let isTextfieldDisabled: Bool
    @FocusState var isTextFieldFocused: Bool
    
    let placeholderText: String
    let isSearchBar: Bool
    
    private var textFieldStrokeColor: Color {
        if isWrongText {
            return Color(hexCode: "F05650")
        }
        return isTextFieldFocused ? Color(hexCode: "#666666") : Color(hexCode: "f2f2f2")
    }
    
    var body: some View {
        HStack {
            HStack {
                if isSearchBar {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(colorScheme == .light ? .black : .white)
                        .padding(.leading, 5)
                }
                
                TextField(placeholderText, text: $text)
                    .submitLabel(.search)
                    .focused($isTextFieldFocused)
                    .disabled(isTextfieldDisabled)
                    .padding(.leading, isSearchBar ? 0 : 10)
                    .textInputAutocapitalization(.never)
                    .accentColor(colorScheme == .light ? .black : .white)
                
                if !text.isEmpty && isTextFieldFocused {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(isWrongText ? .red : colorScheme == .light ? .black : .white)
                    }
                    .padding(.trailing, 16)
                }
            }
            .frame(height: 44)
            
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorScheme == .dark ? Color(hexCode: "3E505B") : Color(hexCode: "F2F2F2"))
            )

            if isSearchBar && isTextFieldFocused {
                Button {
                    isTextFieldFocused = false
                } label: {
                    Text("취소")
                        .foregroundColor(Color(hexCode: "8AB0AB"))
                }
            }
        }
    }
}

#Preview {
    RMTextField(
        text: .constant(""),
        isWrongText: false,
        isTextfieldDisabled: false,
        isTextFieldFocused: FocusState(),
        placeholderText: "검색어를 입력하세요.",
        isSearchBar: true
    )
}
