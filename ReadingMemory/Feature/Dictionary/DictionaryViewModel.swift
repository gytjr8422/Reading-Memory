//
//  DictionaryViewModel.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/26/24.
//

import Foundation

final class DictionaryViewModel: ObservableObject {
    private let dictionaryUrl: String = "https://opendict.korean.go.kr/api/search"
    
    @Published var dictionaryList: [WordItem] = []
    @Published var isApiConnected: Bool = true
    
    func searchDictionary(_ searchString: String) async {
        if searchString.count < 1 { return }
        guard let apikey = Bundle.main.dictionaryApiKey else { return }
        
        var urlComponents = URLComponents(string: dictionaryUrl)
        urlComponents?.queryItems = [
            URLQueryItem(name: "key", value: apikey),
            URLQueryItem(name: "advanced", value: "y"),
            URLQueryItem(name: "q", value: searchString),
            URLQueryItem(name: "part", value: "word"),
            URLQueryItem(name: "sort", value: "popular"),
            URLQueryItem(name: "num", value: "20"),
            URLQueryItem(name: "req_type", value: "json")
        ]
        
        if let urlComponents, let url = urlComponents.url {
            let request = URLRequest(url: url)
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let jsonDecoder = JSONDecoder()
                let dictionaryResult = try jsonDecoder.decode(DictionaryResult.self, from: data)
                
                DispatchQueue.main.async {
                    self.isApiConnected = true
                    self.dictionaryList = dictionaryResult.channel.item
                }
            } catch {
                DispatchQueue.main.async {
                    self.isApiConnected = false
                }
                print("Dictionary Fetch Error: \(error)")
            }
        }
    }
}
