//
//  SpaceTimeDataManager.swift
//
//
//  Created by 리아 on 5/24/24.
//

import CoreData

class SpaceTimeDataManager {
    static func fetchSpaceTimeData(for video: ARVideo, in context: NSManagedObjectContext) -> [SpaceTime] {
        let fetchRequest: NSFetchRequest<SpaceTime> = SpaceTime.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "cameraInfoOrigin == %@", video),
            NSPredicate(format: "modelInfoOrigin == %@", video)
        ])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch SpaceTime data: \(error.localizedDescription)")
            return []
        }
    }
    
    static func fetchCameraData(for video: ARVideo, in context: NSManagedObjectContext) -> [SpaceTime] {
        let fetchRequest: NSFetchRequest<SpaceTime> = SpaceTime.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "cameraInfoOrigin == %@", video)
        ])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch camera SpaceTime data: \(error.localizedDescription)")
            return []
        }
    }
    
    static func fetchModelData(for video: ARVideo, in context: NSManagedObjectContext) -> [SpaceTime] {
        let fetchRequest: NSFetchRequest<SpaceTime> = SpaceTime.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "modelInfoOrigin == %@", video)
        ])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch model SpaceTime data: \(error.localizedDescription)")
            return []
        }
    }
}

