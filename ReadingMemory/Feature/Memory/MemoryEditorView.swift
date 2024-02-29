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
    @ObservedResults(Sentence.self) private var sentences
    @ObservedResults(Word.self) private var words
    @ObservedResults(Thought.self) private var thoughts
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var firstText: String = ""
    @State private var secondText: String = ""
    @State private var thirdText: String = ""
    @State private var pageText: String = ""
    @State private var isSavedSuccess: Bool = false
    @State private var isShowingCancelAlert: Bool = false
    @State private var isShowingEmptyAlert: Bool = false
    
    @Binding var isShowingEditSheet: Bool
    let book: Book?
    let editCategory: MemoryCategory
    let editorMode: EditorMode
    let memoryId: ObjectId?
    
    init(firstText: String, secondText: String, isShowingEditSheet: Binding<Bool>, book: Book?, editCategory: MemoryCategory, editorMode: EditorMode, memoryId: ObjectId?) {
        self._firstText = State(initialValue: firstText)
        self._secondText = State(initialValue: secondText)
        self._isShowingEditSheet = Binding(projectedValue: isShowingEditSheet)
        self.book = book
        self.editCategory = editCategory
        self.editorMode = editorMode
        self.memoryId = memoryId
    }
    
    var firstTitle: String {
        switch editCategory {
        case .sentence:
            return "기억할 문장"
        case .word:
            return "기억할 단어"
        case .thought:
            return "갈무리"
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
            return UIScreen.main.bounds.height * 0.4
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
                editorView
            }
            .background(colorScheme == .light ? .white : Color.backgroundBlue)
            .scrollDismissesKeyboard(.immediately)
        }
        .tint(colorScheme == .light ? .black : .white)
        .onAppear {
            switch editorMode {
            case .add:
                break
            case .modify:
                switch editCategory {
                case .sentence:
                    if let sentence = book?.sentences.first(where: { $0.id == memoryId }) ?? sentences.first(where: { $0.id == memoryId }) {
                        firstText = sentence.sentence
                        thirdText = sentence.idea
                        pageText = sentence.page
                    }                case .word:
                    if let word = book?.words.first(where: { $0.id == memoryId }) ?? words.first(where: { $0.id == memoryId }) {
                        firstText = word.word
                        secondText = word.meaning
                        thirdText = word.sentence
                        pageText = word.page
                    }
                case .thought:
                    if let thought = book?.thoughts.first(where: { $0.id == memoryId }) ?? thoughts.first(where: { $0.id == memoryId }) {
                        firstText = thought.thought
                        pageText = thought.page
                    }
                }
            }
        }
        .alert("\(firstTitle)을 작성해주세요.", isPresented: $isShowingEmptyAlert, actions: {
            Button {
                isShowingEditSheet = true
            } label: {
                Text("확인")
            }

        })
        .alert("작성/수정을 취소하시겠습니까?", isPresented: $isShowingCancelAlert, actions: {
            Button("계속 작성하기", role: .cancel) { }
            
            Button("나가기", role: .destructive) {
                isShowingEditSheet = false
            }
        }, message: {
            Text("취소 시 작성 및 수정한 기록은 저장되지 않습니다.")
        })
    }
    
    private var editorView: some View {
        VStack(alignment: .leading) {
            HStack {
                makeTitle(firstTitle)
                    .padding(.trailing, 5)
                
                Text("페이지")
                makePageTextField($pageText)
            }
            makeTextEditor($firstText, height: firstEditorHeight)
            
            if editCategory == .word {
                makeTitle(secondTitle)
                makeTextEditor($secondText, height: secondEditorHeight)
            }
            
            if editCategory == .sentence || editCategory == .word {
                makeTitle(thirdTitle)
                makeTextEditor($thirdText, height: thirdEditorHeight)
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
                                isShowingCancelAlert = true
                            }
                        } else {
                            isShowingEditSheet = false
                        }
                    } else {
                        isShowingCancelAlert = true
                    }
                } label: {
                    Text("취소")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    firstText = firstText.trimmingCharacters(in: .whitespacesAndNewlines)
                    secondText = secondText.trimmingCharacters(in: .whitespacesAndNewlines)
                    thirdText = thirdText.trimmingCharacters(in: .whitespacesAndNewlines)
                    switch editorMode {
                    case .add:
                        if firstText.isEmpty {
                            isShowingEmptyAlert = true
                        } else {
                            Book.addMemory(book, category: editCategory, firstText: firstText, secondText: secondText, thirdText: thirdText, pageText: pageText)
                            isShowingEditSheet = false
                        }
                    case .modify:
                        if firstText.isEmpty {
                            isShowingEmptyAlert = true
                        } else {
                            Book.editMemory(book, memoryId: memoryId, category: editCategory, firstText: firstText, secondText: secondText, thirdText: thirdText, pageText: pageText)
                            isShowingEditSheet = false
                        }
                    }
                } label: {
                    Text("저장")
                }
            }
        })
    }
    
    private func makeTitle(_ title: String) -> some View {
        Text(title)
            .bold()
            .font(.title2)
            .foregroundStyle(colorScheme == .light ? .black : .white)
    }
    
    private func makePageTextField(_ pageText: Binding<String>) -> some View {
        TextField("", text: $pageText)
            .font(.callout)
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(colorScheme == .light ? Color(hexCode: "DCE2F0") : Color(hexCode: "22333B"))
                    .frame(width: UIScreen.main.bounds.width * 0.13, height:  UIScreen.main.bounds.width * 0.07)
            )
            .frame(width: UIScreen.main.bounds.width * 0.1, height: UIScreen.main.bounds.width * 0.07)
            .keyboardType(.numberPad)
            .padding(.horizontal, 5)
            .overlay {
                RoundedRectangle(cornerRadius: 7)
                    .stroke(lineWidth: 1)
            }
    }

    private func makeTextEditor(_ text: Binding<String>, height: CGFloat) -> some View {
        TextEditor(text: text)
            .frame(width: UIScreen.main.bounds.width * 0.9, height: height)
            .scrollContentBackground(.hidden) // 기본 배경 숨기기
            .background(colorScheme == .light ? Color(hexCode: "DCE2F0") : Color(hexCode: "22333B"))
            .font(.body)
            .foregroundColor(colorScheme == .light ? .black : .white)
            .padding(2)
            .lineSpacing(7)
            .multilineTextAlignment(.leading)
            .overlay {
                RoundedRectangle(cornerRadius: 7)
                    .stroke(lineWidth: 1)
            }
            .padding(.bottom)
    }
    
}

#Preview {
    MemoryEditorView(firstText: "", secondText: "", isShowingEditSheet: .constant(true), book:Book.dummyBook, editCategory: .word, editorMode: .add, memoryId: nil)
}
