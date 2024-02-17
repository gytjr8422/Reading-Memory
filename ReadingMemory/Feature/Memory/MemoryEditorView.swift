//
//  MemoryEditorView.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/12/24.
//

import RealmSwift
import SwiftUI


// 기억하기로 넘어오면 빈 텍스트, 수정으로 들어오면 해당 메모로 채우기
struct MemoryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var firstText: String = ""
    @State private var secondText: String = ""
    @State private var thirdText: String = ""
    @State private var pageText: String = ""
    @State private var isSavedSuccess: Bool = false
    @State private var isShowingAlert: Bool = false
    
    @FocusState private var isFirstFocused: Bool
    @FocusState private var isSecondFocused: Bool
    @FocusState private var isThirdFocused: Bool
    @FocusState private var isPageFocused: Bool
    
    @Binding var isShowingEditSheet: Bool
    let book: Book
    let editCategory: MemoryCategory
    
    var firstTitle: String {
        switch editCategory {
        case .sentence:
            return "기억할 문장"
        case .word:
            return "기억할 단어"
        case .thought:
            return "내 생각"
        }
    }
    
    var secondTitle: String {
        switch editCategory {
        case .sentence:
            return ""
        case .word:
            return "뜻"
        case .thought:
            return ""
        }
    }
    
    var thirdTitle: String {
        switch editCategory {
        case .sentence:
            return "내 생각"
        case .word:
            return "나온 문장"
        case .thought:
            return ""
        }
    }
    
    var firstEditorHeight: CGFloat {
        switch editCategory {
        case .sentence:
            return UIScreen.main.bounds.height / 3
        case .word:
            return UIScreen.main.bounds.height * 0.07
        case .thought:
            return UIScreen.main.bounds.height * 0.7
        }
    }
    
    var secondEditorHeight: CGFloat {
        switch editCategory {
        case .word:
            return UIScreen.main.bounds.height / 3
        default:
            return 0
        }
    }
    
    var thirdEditorHeight: CGFloat {
        switch editCategory {
        case .sentence, .word:
            return UIScreen.main.bounds.height / 3
        default:
            return 0
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Text(firstTitle)
                            .bold()
                            .font(.title2)
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                        Spacer()
                        
                        Text("페이지")
//                        TextMaster(text: $pageText, isFocused: $isPageFocused, maxLine: 1, fontSize: 17, height: UIScreen.main.bounds.height * 0.03)
                        TextField("", text: $pageText)
                            .font(.callout)
                            .background(
                                Rectangle()
                                    .fill(colorScheme == .light ? Color(hexCode: "DCE2F0") : Color(hexCode: "22333B"))
                                    .frame(width: 70, height: 25)
                            )
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                            .padding(.horizontal, 5)
                    }
                    TextMaster(text: $firstText, isFocused: $isFirstFocused, maxLine: editCategory == .word ? 2 : 10, fontSize: 17, height: firstEditorHeight)
                        .background(colorScheme == .light ? Color(hexCode: "DCE2F0") : Color(hexCode: "22333B"))
                        .padding(.bottom)
                    
                    if editCategory == .word {
                        Text(secondTitle)
                            .bold()
                            .font(.title2)
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                        TextMaster(text: $secondText, isFocused: $isSecondFocused, maxLine: 10, fontSize: 17, height: secondEditorHeight)
                            .background(colorScheme == .light ? Color(hexCode: "DCE2F0") : Color(hexCode: "22333B"))
                            .padding(.bottom)
                    }
                    
                    if editCategory == .sentence || editCategory == .word {
                        Text(thirdTitle)
                            .bold()
                            .font(.title2)
                        TextMaster(text: $thirdText, isFocused: $isThirdFocused, maxLine: 10, fontSize: 17, height: thirdEditorHeight)
                            .background(colorScheme == .light ? Color(hexCode: "DCE2F0") : Color(hexCode: "22333B"))
                    }
                }
                .padding(.horizontal)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            if firstText.isEmpty, secondText.isEmpty {
                                if editCategory == .word {
                                    if thirdText.isEmpty {
                                        isShowingEditSheet = false
                                    } else {
                                        isShowingAlert = true
                                    }
                                } else {
                                    isShowingEditSheet = false
                                }
                            } else {
                                isShowingAlert = true
                            }
                        } label: {
                            Text("취소")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Book.addMemory(book, category: editCategory, firstText: firstText, secondText: secondText, thirdText: thirdText, pageText: pageText)
                            dismiss()
                        } label: {
                            Text("저장")
                        }
                    }
                })
                
            }
            .background(colorScheme == .light ? .white : Color.BackgroundBlue)
            .scrollDismissesKeyboard(.immediately)
        }
        .accentColor(colorScheme == .light ? .black : .white)
        .alert("취소 시 작성한 기록은 저장되지 않습니다.", isPresented: $isShowingAlert) {
            Button {
                
            } label: {
                Text("계속 작성하기")
            }
            
            Button {
                isShowingEditSheet = false
            } label: {
                Text("나가기")
            }
        }
    }
}

#Preview {
    MemoryEditorView(isShowingEditSheet: .constant(true), book:Book.dummyBook, editCategory: .word)
}
