//
//  CoreDataService.swift
//  Another feed
//
//  Created by Дмитрий Вашлаев on 11.08.18.
//  Copyright © 2018 Дмитрий Вашлаев. All rights reserved.
//

import Foundation
import CoreData

fileprivate let entityName = "NewsEntity"

class CoreDataService {
    // MARK: - Public properties
    private(set) var newsList = [NewsEntity]()
    
    // MARK: - Core Data stack
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Another_feed")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    
    // MARK: - Initializers
    init() {
        self.newsList = fetchData()
    }
    
    // MARK: - Public methods
    func saveArray(newsList: [NewsData]) {
        for item in newsList {
            let dateFormatter = ISO8601DateFormatter()
            var date: Date?
            if let _ = item.publishedAt {
                date = dateFormatter.date(from:item.publishedAt!)
            }
            
            // check whether news already exists
            if !self.newsList.contains(where: {$0.title == item.title && $0.publishedAt == date}) {
                let newElement = NewsEntity(context: CoreDataService.persistentContainer.viewContext)
                newElement.author = item.author
                newElement.title = item.title
                newElement.newsDescription = item.description
                newElement.url = item.url
                newElement.urlToImage = item.urlToImage
                newElement.publishedAt = date
                
                self.newsList.append(newElement)
            }
        }
        
        self.newsList.sort {
            guard let dateOne = $0.publishedAt, let dateTwo = $1.publishedAt else { return false }
            return dateOne > dateTwo
        }
        
        CoreDataService.saveContext()
    }
    
    func updateEntityWith(_ data: Data?, at index: Int) {
        newsList[index].image = data
        CoreDataService.saveContext()
        
        // make a notification
        let name = Notification.Name(rawValue: NotificationKeys.updateImage.rawValue)
        NotificationCenter.default.post(name: name, object: nil, userInfo: ["news":newsList[index]])
    }
    
    // MARK: - Private methods
    private func fetchData() -> [NewsEntity] {
        let fetchRequest = NewsEntity.fetchRequest() as NSFetchRequest<NewsEntity>
        let sortDescriptorDate = NSSortDescriptor(key: "publishedAt", ascending: false)
        fetchRequest.sortDescriptors?.append(sortDescriptorDate)
        
        var list = [NewsEntity]()
        
        do {
            list = try CoreDataService.persistentContainer.viewContext.fetch(fetchRequest)
        } catch let fetchingError {
            print("Core data fetching error:", fetchingError)
        }
        
        return list
    }
}
