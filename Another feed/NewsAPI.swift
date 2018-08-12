//
//  NewsAPI.swift
//  Another feed
//
//  Created by Дмитрий Вашлаев on 11.08.18.
//  Copyright © 2018 Дмитрий Вашлаев. All rights reserved.
//

import Foundation

fileprivate let apiKey = "370c24a0f015402ea3e866054decf80b"
let pageSize = 20 // standard page size

enum Language: String {
    case en
    case ru
}

enum APIParameters: String {
    case everything = "https://newsapi.org/v2/everything?"
    case q
    case sources
    case domains
    case from
    case to
    case language
    case sortBy
    case pageSize
    case page
    case apiKey
}

class NewsAPI {
    func downloadAllNews(source: String, page: Int, completionHandler: @escaping (Data?) -> Void) {
        // Compose search request
        let concatenatedString = "\(APIParameters.everything.rawValue)\(APIParameters.sources)=\(source)&\(APIParameters.page)=\(page)&\(APIParameters.apiKey)=\(apiKey)"
        guard let encondedString = concatenatedString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else { return }
        guard let url = URL(string: encondedString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, urlRsponse, err) in
            completionHandler(data)
            }.resume()
    }
}

