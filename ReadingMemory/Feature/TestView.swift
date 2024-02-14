//
//  TestView.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/7/24.
//

import SwiftUI

struct TestView: View {
    @EnvironmentObject var router: Router
    private let colors: [Color] = [.red, .green, .blue, .yellow, .cyan, .orange, .purple, .black, .brown, .gray]
    
    
    var body: some View {
        if #available(iOS 17.0, *) {
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(0..<10) { i in
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width / 3, height: 200)
                            .foregroundStyle(colors[i])
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned(limitBehavior: .automatic))
            .padding()
        } else {
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(0..<10) { i in
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width / 3, height: 200)
                            .foregroundStyle(colors[i])
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    TestView()
}
