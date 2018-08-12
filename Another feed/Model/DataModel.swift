//
//  DataModel.swift
//  Another feed
//
//  Created by Дмитрий Вашлаев on 11.08.18.
//  Copyright © 2018 Дмитрий Вашлаев. All rights reserved.
//

import UIKit
import CoreData

fileprivate let sourcesFileName = "Sources"

enum SourceAttributes: String {
    case sourceName = "Source name"
    case parameter = "Parameter"
}

struct Source {
    var sourceName: String?
    var parameter: String?
}

class DataModel {
    // MARK: - Private properties
    private var sources: [Source] = {
        var newSources = [Source]()
        
        // getting news sources from .plist
        if let url = Bundle.main.url(forResource: sourcesFileName, withExtension: "plist") {
            do {
                let data = try Data(contentsOf: url)
                let myPlist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [[String:String]]
                for item in myPlist {
                    let source = Source(sourceName: item[SourceAttributes.sourceName.rawValue], parameter: item[SourceAttributes.parameter.rawValue])
                    newSources.append(source)
                }
            } catch let serializationError {
                print("Plist serialization error: ", serializationError)
            }
        }
        
        return newSources
    }()
    
    private var coreDataService: CoreDataService
    
    // MARK: - Initializers
    init(_ coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
    }
    
    // MARK: - Public methods
    func downloadAllNews(page: Int = 1, completionHandler: @escaping () -> Void) {
        let service = NewsAPI()
        var concatenatedSource = ""
        
        for item in sources {
            if let _ = item.parameter {
                concatenatedSource += "\(item.parameter!),"
            }
        }
        concatenatedSource = String(concatenatedSource.dropLast())
        
        service.downloadAllNews(source: concatenatedSource, page: page) { [weak self] (receivedData) in
            do {
                guard let weakSelf = self else { return }
                guard let data = receivedData else { return }
                // Parsing JSON
                let result = try JSONDecoder().decode(reply.self, from: data)
                
                if let array = result.articles {
                    weakSelf.coreDataService.saveArray(newsList: array)
                    weakSelf.downloadImages()
                    completionHandler()
                }
                
            } catch let jsonErr {
                print("JSON serialization error:", jsonErr)
            }
        }
    }
    
    func getNews() -> [NewsEntity] {
        return coreDataService.newsList
    }
    
    // MARK: - Private methods
    private func downloadImages() {
        for item in coreDataService.newsList {
            if item.image != nil {
                continue
            }
            
            guard let urlString = item.urlToImage, let url = URL(string: urlString) else { return }
            URLSession.shared.dataTask(with: url) { [weak self] (data, urlRsponse, err) in
                guard let weakSelf = self else { return }
                if let index = weakSelf.coreDataService.newsList.index(of: item) {
                    weakSelf.coreDataService.updateEntityWith(data, at: index)
                }
                }.resume()
        }
    }
}
