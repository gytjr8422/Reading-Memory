//
//  Bundle+Extensions.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/14/24.
//

import Foundation

extension Bundle {
    var kakaoApiKey: String? {
        return infoDictionary?["KAKAO_API_KEY"] as? String
    }
    
    var naverClientKey: String? {
        return infoDictionary?["NAVER_CLIENT_KEY"] as? String
    }
    
    var naverSecretKey: String? {
        return infoDictionary?["NAVER_SECRET_KEY"] as? String
    }
    
    var dictionaryApiKey: String? {
        return infoDictionary?["DICTIONARY_API_KEY"] as? String
    }
}
