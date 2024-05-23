//
//  ARTrackingCoordinator.swift
//  ARMotionCam
//
//  Created by 리아 on 5/2/24.
//

import ARKit
import CoreData
import RealityKit

class ARTrackingCoordinator: NSObject, ARSessionDelegate {
    
    enum TrackingType: String {
        case camera = "Camera"
        case model = "Model"
    }
    
    private var viewContext: NSManagedObjectContext
    private var currentARVideo: ARVideo?
    var timer: Timer?
    
    init(_ viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.currentARVideo = ARTrackingCoordinator.createNewARVideo(context: viewContext)
    }
    
    func startTracking(in arView: ARView) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            self?.updateTrackingData(arView: arView)
        }
    }
    
    func stopTracking(at videoURL: URL? = nil) {
        timer?.invalidate()
        
        guard let arVideo = currentARVideo else {
            print("No ARVideo context available")
            return
        }
        arVideo.videoUrl = videoURL?.absoluteString
        
        do {
            try viewContext.save()
            print("Saved video url : \(String(describing: videoURL?.absoluteString)) successfully")
        } catch {
            print("Failed to save video url \(String(describing: videoURL?.absoluteString))): \(error.localizedDescription)")
        }
    }
    
    private func updateTrackingData(arView: ARView) {
        // Track target's position and orientation relative to world coordinates
        if let targetEntity = (arView.scene.anchors.first as? AnchorEntity)?
            .children.first as? ModelEntity {
            let targetPosition = targetEntity.position(relativeTo: nil)
            let targetOrientation = targetEntity.orientation(relativeTo: nil)
            
            self.saveTrackingData(type: .model, position: targetPosition, orientation: targetOrientation)
        }

        if let cameraTransform = arView.session.currentFrame?.camera.transform {
            let cameraPosition = SIMD3<Float>(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
            let cameraOrientation = simd_quatf(cameraTransform)

            self.saveTrackingData(type: .camera, position: cameraPosition, orientation: cameraOrientation)
        }
    }
    
    private func saveTrackingData(type: TrackingType, position: SIMD3<Float>, orientation: simd_quatf) {
        guard let arVideo = currentARVideo else {
            print("No ARVideo context available")
            return
        }
        
        let trackingData = SpaceTime(context: viewContext)
        
        trackingData.timestamp = Date()
        trackingData.positionX = position.x
        trackingData.positionY = position.y
        trackingData.positionZ = position.z
        trackingData.orientationX = orientation.vector.x
        trackingData.orientationY = orientation.vector.y
        trackingData.orientationZ = orientation.vector.z
        trackingData.orientationW = orientation.vector.w
        
        switch type {
        case .camera:
            trackingData.cameraInfoOrigin = arVideo
            arVideo.addToCameraInfo(trackingData)
        case .model:
            trackingData.modelInfoOrigin = arVideo
            arVideo.addToModelInfo(trackingData)
        }
        
        do {
            try viewContext.save()
            print("Saved \(type)_\(String(describing: trackingData.timestamp)) successfully")
            print("Position: \(position), Orientation: \(orientation)")
        } catch {
            print("Failed to save \(type)_\(String(describing: trackingData.timestamp)): \(error.localizedDescription)")
        }
    }
    
    static func createNewARVideo(context: NSManagedObjectContext, with url: URL? = nil) -> ARVideo {
        let newARVideo = ARVideo(context: context)
        newARVideo.createdAt = Date()
        newARVideo.index = 0
        newARVideo.videoUrl = url?.absoluteString
        
        do {
            try context.save()
            print("Created new ARVideo context successfully")
        } catch {
            print("Failed to create new ARVideo context: \(error.localizedDescription)")
        }
        return newARVideo
    }
    
    deinit {
        stopTracking()
    }
}
