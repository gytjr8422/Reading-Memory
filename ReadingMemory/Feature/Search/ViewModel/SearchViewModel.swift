//
//  SearchViewModel.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/12/24.
//

import SwiftUI

final class SearchViewModel: ObservableObject {
    private let kakaoUrl: String = "https://dapi.kakao.com/v3/search/book"
    private let naverUrl: String = "https://openapi.naver.com/v1/search/book.json"
    private var page: Int = 0
    private var isEnd: Bool = false
    
    @Published var books: [BookDocument] = []
    
    /// 제목, 저자로 검색하는 함수
    func searchTitle(_ title: String) async throws {
        var urlComponents = URLComponents(string: kakaoUrl)
        page = 1
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "query", value: title),
            URLQueryItem(name: "size", value: "15")
        ]
        
        if let urlComponents, let url = urlComponents.url, let apikey = Bundle.main.kakaoApiKey {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("KakaoAK \(apikey)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let jsonDecoder = JSONDecoder()
                let searchResult = try jsonDecoder.decode(SearchResult.self, from: data)
                DispatchQueue.main.async {
                    self.books = searchResult.documents
                }
            } catch {
                print("Error: \(error)")
            }
        }
        
    }
    
    func additionalSearch(_ title: String) async throws -> Bool {
        
        var urlComponents = URLComponents(string: kakaoUrl)
        page += 1
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "query", value: title),
            URLQueryItem(name: "size", value: "15"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        if let urlComponents, let url = urlComponents.url, let apikey = Bundle.main.kakaoApiKey {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("KakaoAK \(apikey)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let jsonDecoder = JSONDecoder()
                let searchResult = try jsonDecoder.decode(SearchResult.self, from: data)
                DispatchQueue.main.async {
                    self.books += searchResult.documents
                }
            } catch {
                print("Error: \(error)")
            }
        }
        
        return isEnd
    }
    
    /// isbn으로 검색해서 book description을 반환하는 함수
    func searchIsbn(_ isbn: String) async throws -> String {
        var naverComponets = URLComponents(string: naverUrl)
        
        naverComponets?.queryItems = [
            URLQueryItem(name: "query", value: isbn),
        ]
        
        if let naverComponets, let url = naverComponets.url, let naverClient = Bundle.main.naverClientKey, let naverSecret = Bundle.main.naverSecretKey {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue(naverClient, forHTTPHeaderField: "X-Naver-Client-Id")
            request.addValue(naverSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let jsonDecoder = JSONDecoder()
                let searchResult = try jsonDecoder.decode(NaverResult.self, from: data)
                return searchResult.items.count > 0 ? searchResult.items[0].description : ""
            } catch {
                print("Error: \(error)")
            }
        }
        
        return ""
    }
    
    func getAverageColor(_ urlString: String) async -> UIColor {
        guard let url = URL(string: urlString) else { return UIColor.gray }
        do {
            let uiImage = try await fetchImage(from: url)
            guard let uiColor = uiImage?.averageColor else { return UIColor.gray }
            return uiColor
        } catch {
            // Handle errors, for example, print an error message.
            print("Error fetching image: \(error)")
            return UIColor.gray
        }
    }
    
    func fetchImage(from url: URL) async throws -> UIImage? {
        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)
    }
}
