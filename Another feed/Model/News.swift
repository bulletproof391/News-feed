//
//  News.swift
//  Another feed
//
//  Created by Дмитрий Вашлаев on 11.08.18.
//  Copyright © 2018 Дмитрий Вашлаев. All rights reserved.
//

import Foundation

struct reply: Decodable {
    var status: String?
    var totalResults: Int?
    var articles: [NewsData]?
}

struct NewsData: Decodable {
    var author: String?
    var title: String?
    var description: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: String?
}

