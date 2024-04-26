//
//  PersistenceController.swift
//  ARMotionCam
//
//  Created by 리아 on 4/12/24.
//

import Foundation
import CoreData

struct Persistence {
    static let shared = Persistence()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        let TrackedDataEntity = NSEntityDescription()
        TrackedDataEntity.name = "TrackedData"
        TrackedDataEntity.managedObjectClassName = "TrackingData"
        
        let typeAttribute = NSAttributeDescription()
        typeAttribute.name = "type"
        typeAttribute.type = .string
        TrackedDataEntity.properties.append(typeAttribute)
        
        let timestampAttribute = NSAttributeDescription()
        timestampAttribute.name = "timestamp"
        timestampAttribute.type = .date
        TrackedDataEntity.properties.append(timestampAttribute)
        
        let positionXAttribute = NSAttributeDescription()
        positionXAttribute.name = "positionX"
        positionXAttribute.type = .float
        TrackedDataEntity.properties.append(positionXAttribute)
        
        let positionYAttribute = NSAttributeDescription()
        positionYAttribute.name = "positionY"
        positionYAttribute.type = .float
        TrackedDataEntity.properties.append(positionYAttribute)
        
        let positionZAttribute = NSAttributeDescription()
        positionZAttribute.name = "positionZ"
        positionZAttribute.type = .float
        TrackedDataEntity.properties.append(positionZAttribute)
        
        let orientationXAttribute = NSAttributeDescription()
        orientationXAttribute.name = "orientationX"
        orientationXAttribute.type = .float
        TrackedDataEntity.properties.append(orientationXAttribute)
        
        let orientationYAttribute = NSAttributeDescription()
        orientationYAttribute.name = "orientationY"
        orientationYAttribute.type = .float
        TrackedDataEntity.properties.append(orientationYAttribute)
        
        let orientationZAttribute = NSAttributeDescription()
        orientationZAttribute.name = "orientationZ"
        orientationZAttribute.type = .float
        TrackedDataEntity.properties.append(orientationZAttribute)
        
        let orientationWAttribute = NSAttributeDescription()
        orientationWAttribute.name = "orientationW"
        orientationWAttribute.type = .float
        TrackedDataEntity.properties.append(orientationWAttribute)
        
        let model = NSManagedObjectModel()
        model.entities = [TrackedDataEntity]
        
        let container = NSPersistentContainer(name: "TrackedData", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        self.container = container
    }
}
