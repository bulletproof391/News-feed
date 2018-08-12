//
//  CellViewModel.swift
//  Another feed
//
//  Created by Дмитрий Вашлаев on 12.08.18.
//  Copyright © 2018 Дмитрий Вашлаев. All rights reserved.
//

import UIKit

class CellViewModel {
    // MARK: - Public properties
    private(set) var title: String?
    private(set) var description: String?
    private(set) var publishedAt: Date?
    private(set) var image: UIImage?
    
    // MARK: - Private properties
    private var urlToImage: String?
    
    // MARK: - Initializers
    init(news: NewsEntity) {
        self.title = news.title
        self.description = news.newsDescription
        self.urlToImage = news.urlToImage
        self.publishedAt = news.publishedAt
        
        if let imageData = news.image {
            self.image = UIImage(data: imageData)
        }
    }
}
