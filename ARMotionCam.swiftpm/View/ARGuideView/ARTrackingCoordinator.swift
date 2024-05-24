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
    private var recordInfo: RecordingInfo
    private var currentARVideo: ARVideo?
    private var isContextStart: Bool = false
    var timer: Timer?
    
    init(_ viewContext: NSManagedObjectContext, recordInfo: RecordingInfo) {
        self.viewContext = viewContext
        self.recordInfo = recordInfo
    }
    
    func startTracking(in arView: ARView) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            guard let isRec =  self?.recordInfo.isRecording,
            let isStart = self?.isContextStart else { return }
            
            if isRec { self?.updateTrackingData(arView: arView) }
            else if isStart { self?.stopTracking() }
        }
    }
    
    private func stopTracking() {
        timer?.invalidate()
        isContextStart = false
        
        guard let arVideo = currentARVideo else { return }
        arVideo.videoUrl = recordInfo.currentURL.absoluteString
        
        do {
            try viewContext.save()
            print("Saved video url : \(String(describing: arVideo.videoUrl)) successfully")
        } catch {
            print("Failed to save video url \(String(describing: arVideo.videoUrl))): \(error.localizedDescription)")
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
        currentARVideo = isContextStart ? currentARVideo : createNewARVideo(context: viewContext)
        let arVideo = currentARVideo ?? createNewARVideo(context: viewContext)
        let trackingData = SpaceTime(context: viewContext)
        
        isContextStart = true
        
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
    
    private func createNewARVideo(context: NSManagedObjectContext, with url: URL? = nil) -> ARVideo {
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
