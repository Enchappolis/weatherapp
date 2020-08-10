//
//  CDCityWeatherCoreDataHandler.swift
//  weatherapp
//
//  Created by Enchappolis on 7/29/20.
//  Copyright © 2020 Enchappolis. All rights reserved.
//  https://github.com/Enchappolis
/*
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 distribute, sublicense, create a derivative work, and/or sell copies of the
 Software in any work that is designed, intended, or marketed for pedagogical or
 instructional purposes related to programming, coding, application development,
 or information technology.  Permission for such use, copying, modification,
 merger, publication, distribution, sublicensing, creation of derivative works,
 or sale is expressly withheld.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
*/

import Foundation
import CoreData

class CDCityWeatherCoreDataHandler {
    
    // MARK: - Core Data
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "weatherapp")
        
        // Enable remote notifications
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { storeDesription, error in
            guard error == nil else {
                fatalError("Unresolved error \(error!)")
            }
        }
        
        // This sample refreshes UI by refetching data, so doesn't need to merge the changes.
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        
        return container
    }()
    
    private func newTaskContext() -> NSManagedObjectContext {
        // Create a private queue context.
        let taskContext = persistentContainer.newBackgroundContext()
        taskContext.automaticallyMergesChangesFromParent = true
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return taskContext
    }
    
    // MARK: - NSFetchedResultsController
    weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    
    lazy var fetchedResultsController: NSFetchedResultsController<CDCityWeather> = {
        
        let fetchRequest = NSFetchRequest<CDCityWeather>(entityName: "CDCityWeather")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = fetchedResultsControllerDelegate
        
        do {
            try controller.performFetch()
        } catch {
            fatalError("Unresolved error \(error)")
        }
        
        return controller
    }()
    
    func resetAndRefetch() {
        
        persistentContainer.viewContext.reset()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Unresolved error \(error)")
        }
    }
    
    // MARK: - Read
    func fetchSelectedCityWeater(completion: @escaping (_ cdCityWeather: CDCityWeather?) -> ()) {
        
        let cityWeatherFetchRequest = NSFetchRequest<CDCityWeather>(entityName: CDCityWeather.entityName)
        
        cityWeatherFetchRequest.predicate = NSPredicate(format: "selected == %@", NSNumber(booleanLiteral: true))
        
        do {
            
            let cdCityWeather = try self.persistentContainer.viewContext.fetch(cityWeatherFetchRequest).first
            
            DispatchQueue.main.async {
                completion(cdCityWeather)
            }
            
        }
        catch {
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }
        //        }
    }
    
    // MARK: - Insert
    func insertCityWeather(city: WACity) throws {
        
        let taskContext = newTaskContext()
        var performError: Error?
        
        // taskContext.performAndWait runs on the URLSession's delegate queue
        // so it won’t block the main thread.
        taskContext.performAndWait {
            
            guard let cityWeather = NSEntityDescription.insertNewObject(forEntityName: "CDCityWeather", into: taskContext) as? CDCityWeather else {
                
                performError = CDCityWeatherError.creationError
                return
            }
            
            do {
                
                try cityWeather.insert(city: city)
                
            } catch {

                performError = CDCityWeatherError.creationError
            }
            
            if taskContext.hasChanges {
                
                do {
                    
                    try taskContext.save()
                } catch {
                    
                    performError = error
                    return
                }
                
                // Reset the taskContext to free the cache and lower the memory footprint.
                taskContext.reset()
            }
        }
        
        if let error = performError {
            throw error
        }
    }
    
    // MARK: - Update
    private func updateAllToBeNotSeleteced() throws {
        
        let updateRequest = NSBatchUpdateRequest(entityName: CDCityWeather.entityName)
        updateRequest.resultType = .updatedObjectIDsResultType
        updateRequest.propertiesToUpdate = ["selected" : false]
        
        do {
            let result = try self.persistentContainer.viewContext.execute(updateRequest) as? NSBatchUpdateResult

            let changes: [AnyHashable: Any] = [
                NSUpdatedObjectsKey: result?.result as! [NSManagedObjectID]
            ]
            
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.persistentContainer.viewContext])
        }
        catch {
            
            throw CDCityWeatherError.updateError
        }
    }
    
    func update(cityWeather: CDCityWeather) throws {
        
        do {
            
            try updateAllToBeNotSeleteced()
            cityWeather.selected = true
            try persistentContainer.viewContext.save()
            
        } catch {
            
            throw CDCityWeatherError.updateError
        }
    }
    
    // MARK: - Delete
    func delete(cityWeather: CDCityWeather) throws {
        
        persistentContainer.viewContext.delete(cityWeather)
        
        do {
            
            try persistentContainer.viewContext.save()

        } catch {
            
            throw CDCityWeatherError.deleteError
        }
    }
}
