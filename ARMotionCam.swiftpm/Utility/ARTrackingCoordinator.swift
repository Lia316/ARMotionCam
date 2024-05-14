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
    private var viewContext: NSManagedObjectContext
    var timer: Timer?
    
    init(_ viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func startTracking(in arView: ARView) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            self?.updateTrackingData(arView: arView)
        }
    }
    
    private func updateTrackingData(arView: ARView) {
        // Track target's position and orientation relative to world coordinates
        if let targetEntity = (arView.scene.anchors.first as? AnchorEntity)?
            .children.first as? ModelEntity {
            let targetPosition = targetEntity.position(relativeTo: nil)
            let targetOrientation = targetEntity.orientation(relativeTo: nil)
            
            self.saveTrackingData(type: "Target", position: targetPosition, orientation: targetOrientation)
        }

        if let cameraTransform = arView.session.currentFrame?.camera.transform {
            let cameraPosition = SIMD3<Float>(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
            let cameraOrientation = simd_quatf(cameraTransform)

            self.saveTrackingData(type: "Camera", position: cameraPosition, orientation: cameraOrientation)
        }
    }
    
    private func saveTrackingData(type: String, position: SIMD3<Float>, orientation: simd_quatf) {
        let trackingData = TrackingData(context: viewContext)
        trackingData.type = type
        trackingData.timestamp = Date()
        trackingData.positionX = position.x
        trackingData.positionY = position.y
        trackingData.positionZ = position.z
        trackingData.orientationX = orientation.vector.x
        trackingData.orientationY = orientation.vector.y
        trackingData.orientationZ = orientation.vector.z
        trackingData.orientationW = orientation.vector.w

        do {
            try viewContext.save()
            print("Saved \(type)_\(trackingData.timestamp) successfully")
            print("Position: \(position), Orientation: \(orientation)")
        } catch {
            print("Failed to save \(type)_\(trackingData.timestamp): \(error.localizedDescription)")
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
