//
//  Persistence2.swift
//
//
//  Created by 리아 on 5/20/24.
//

import CoreData

struct Persistence2 {
    static let shared = Persistence2()
    
    let container: NSPersistentContainer
    
    private init() {
        let model = Persistence2.createCoreDataModel()
        let container = NSPersistentContainer(name: "ARVideoInfo", managedObjectModel: model)

        let storeURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("ARVideoInfo.sqlite")
        
        // Ensure the directory exists
        let storeDirectory = storeURL.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: storeDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError("Failed to create directory: \(error.localizedDescription)")
        }
        
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = NSSQLiteStoreType
        storeDescription.url = storeURL
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core data failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        self.container = container
    }
    
    static func createCoreDataModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // ARVideo entity
        let arVideoEntity = NSEntityDescription()
        arVideoEntity.name = "ARVideo"
        arVideoEntity.managedObjectClassName = NSStringFromClass(ARVideo.self)
        
        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = "createdAt"
        createdAtAttribute.attributeType = .dateAttributeType
        createdAtAttribute.isOptional = true
        
        let indexAttribute = NSAttributeDescription()
        indexAttribute.name = "index"
        indexAttribute.attributeType = .integer32AttributeType
        indexAttribute.defaultValue = 0
        indexAttribute.isOptional = true
        
        let videoUrlAttribute = NSAttributeDescription()
        videoUrlAttribute.name = "videoUrl"
        videoUrlAttribute.attributeType = .stringAttributeType
        videoUrlAttribute.isOptional = true
        
        arVideoEntity.properties = [createdAtAttribute, indexAttribute, videoUrlAttribute]
        
        // SpaceTime entity
        let spaceTimeEntity = NSEntityDescription()
        spaceTimeEntity.name = "SpaceTime"
        spaceTimeEntity.managedObjectClassName = NSStringFromClass(SpaceTime.self)
        
        let orientationWAttribute = NSAttributeDescription()
        orientationWAttribute.name = "orientationW"
        orientationWAttribute.attributeType = .floatAttributeType
        orientationWAttribute.defaultValue = 0.0
        orientationWAttribute.isOptional = true
        
        let orientationXAttribute = NSAttributeDescription()
        orientationXAttribute.name = "orientationX"
        orientationXAttribute.attributeType = .floatAttributeType
        orientationXAttribute.defaultValue = 0.0
        orientationXAttribute.isOptional = true
        
        let orientationYAttribute = NSAttributeDescription()
        orientationYAttribute.name = "orientationY"
        orientationYAttribute.attributeType = .floatAttributeType
        orientationYAttribute.defaultValue = 0.0
        orientationYAttribute.isOptional = true
        
        let orientationZAttribute = NSAttributeDescription()
        orientationZAttribute.name = "orientationZ"
        orientationZAttribute.attributeType = .floatAttributeType
        orientationZAttribute.defaultValue = 0.0
        orientationZAttribute.isOptional = true
        
        let positionXAttribute = NSAttributeDescription()
        positionXAttribute.name = "positionX"
        positionXAttribute.attributeType = .floatAttributeType
        positionXAttribute.defaultValue = 0.0
        positionXAttribute.isOptional = true
        
        let positionYAttribute = NSAttributeDescription()
        positionYAttribute.name = "positionY"
        positionYAttribute.attributeType = .floatAttributeType
        positionYAttribute.defaultValue = 0.0
        positionYAttribute.isOptional = true
        
        let positionZAttribute = NSAttributeDescription()
        positionZAttribute.name = "positionZ"
        positionZAttribute.attributeType = .floatAttributeType
        positionZAttribute.defaultValue = 0.0
        positionZAttribute.isOptional = true
        
        let timestampAttribute = NSAttributeDescription()
        timestampAttribute.name = "timestamp"
        timestampAttribute.attributeType = .dateAttributeType
        timestampAttribute.isOptional = true
        
        spaceTimeEntity.properties = [
            orientationWAttribute,
            orientationXAttribute,
            orientationYAttribute,
            orientationZAttribute,
            positionXAttribute,
            positionYAttribute,
            positionZAttribute,
            timestampAttribute
        ]
        
        // Relationships
        let cameraInfoRelation = NSRelationshipDescription()
        let inverseCameraInfoRelation = NSRelationshipDescription()
        let modelInfoRelation = NSRelationshipDescription()
        let inverseModelInfoRelation = NSRelationshipDescription()
        
        cameraInfoRelation.destinationEntity = spaceTimeEntity
        cameraInfoRelation.name = "cameraInfo"
        cameraInfoRelation.minCount = 0
        cameraInfoRelation.maxCount = 0
        cameraInfoRelation.isOptional = true
        cameraInfoRelation.deleteRule = .nullifyDeleteRule
        cameraInfoRelation.inverseRelationship = inverseCameraInfoRelation
        cameraInfoRelation.isOrdered = true
        
        inverseCameraInfoRelation.destinationEntity = arVideoEntity
        inverseCameraInfoRelation.name = "cameraInfoOrigin"
        inverseCameraInfoRelation.minCount = 0
        inverseCameraInfoRelation.maxCount = 1
        inverseCameraInfoRelation.isOptional = true
        inverseCameraInfoRelation.deleteRule = .nullifyDeleteRule
        inverseCameraInfoRelation.inverseRelationship = cameraInfoRelation
        
        modelInfoRelation.destinationEntity = spaceTimeEntity
        modelInfoRelation.name = "modelInfo"
        modelInfoRelation.minCount = 0
        modelInfoRelation.maxCount = 0
        modelInfoRelation.isOptional = true
        modelInfoRelation.deleteRule = .nullifyDeleteRule
        modelInfoRelation.inverseRelationship = inverseModelInfoRelation
        modelInfoRelation.isOrdered = true
        
        inverseModelInfoRelation.destinationEntity = arVideoEntity
        inverseModelInfoRelation.name = "modelInfoOrigin"
        inverseModelInfoRelation.minCount = 0
        inverseModelInfoRelation.maxCount = 1
        inverseModelInfoRelation.isOptional = true
        inverseModelInfoRelation.deleteRule = .nullifyDeleteRule
        inverseModelInfoRelation.inverseRelationship = modelInfoRelation
        
        arVideoEntity.properties.append(contentsOf: [cameraInfoRelation, modelInfoRelation])
        spaceTimeEntity.properties.append(contentsOf: [inverseCameraInfoRelation, inverseModelInfoRelation])
        
        model.entities = [arVideoEntity, spaceTimeEntity]
        
        return model
    }
}
