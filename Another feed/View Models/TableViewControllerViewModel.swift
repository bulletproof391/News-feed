//
//  File.swift
//  Another feed
//
//  Created by Дмитрий Вашлаев on 11.08.18.
//  Copyright © 2018 Дмитрий Вашлаев. All rights reserved.
//

import Foundation

class TableViewModel {
    // MARK: - Private properties
    private var model: DataModel
    private var cellViewModelList = [CellViewModel]()
    private lazy var currentPage: Int = 1
    
    // MARK: - Initializers
    init(model: DataModel) {
        self.model = model
        
        let newsList = model.getNews()
        if newsList.count > 0 {
            currentPage += newsList.count / pageSize
        }
        
        model.downloadAllNews(page: currentPage) { [weak self] () in
            guard let weakSelf = self else { return }
            
            let newsList = model.getNews()
            weakSelf.initializeCellViewModelListWith(newsList)
            
            // creating notification
            let name = Notification.Name(rawValue: NotificationKeys.isDownloaded.rawValue)
            NotificationCenter.default.post(name: name, object: nil)
        }
        createObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Public methods
    func initializeCellViewModelListWith(_ list: [NewsEntity]) {
        // TODO: - don't remove all view models, just append necessary
        cellViewModelList.removeAll()
        for item in list {
            cellViewModelList.append(CellViewModel(news: item))
        }
    }
    
    func loadNextPage() {
        currentPage += 1
        model.downloadAllNews(page: currentPage) { [weak self] in
            guard let weakSelf = self else { return }
            
            let newsList = weakSelf.model.getNews()
            weakSelf.initializeCellViewModelListWith(newsList)
            
            // creating notification
            let name = Notification.Name(rawValue: NotificationKeys.isDownloaded.rawValue)
            NotificationCenter.default.post(name: name, object: nil)
        }
    }
    
    
    // MARK: - TableView data source
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return cellViewModelList.count
    }
    
    func cellForRowAt(_ indexPath: IndexPath) -> CellViewModel {
        return cellViewModelList[indexPath.row + indexPath.section]
    }
    
    // MARK: - Private methods
    private func createObservers() {
        let name = Notification.Name(NotificationKeys.updateImage.rawValue)
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewModel.updateViewModels(notification:)), name: name, object: nil)
    }
    
    @objc private func updateViewModels(notification: NSNotification) {
        guard let dictionary = notification.userInfo as? [String:NewsEntity], let news = dictionary["news"] else { return }
        let index = cellViewModelList.index {
            guard let title = $0.title, let publishedAt = $0.publishedAt else { return false }
            return title == news.title && publishedAt == news.publishedAt
        }
        
        if let _ = index {
            cellViewModelList[index!] = CellViewModel(news: news)
            
            // create notification to update specific row
            let indexPath = IndexPath(row: index!, section: 0)
            let name = Notification.Name(rawValue: NotificationKeys.updateRow.rawValue)
            NotificationCenter.default.post(name: name, object: nil, userInfo: ["indexPath":indexPath])
        }
    }
}
