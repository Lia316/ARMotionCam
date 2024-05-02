//
//  ARCoordinator.swift
//  ARMotionCam
//
//  Created by 리아 on 5/2/24.
//

import ARKit
import CoreData
import RealityKit
import SwiftUI

class Coordinator: NSObject, ARSessionDelegate {
    private var viewContext: NSManagedObjectContext
    @State private var trackingData = PositionAndOrientation(position: .zero, orientation: simd_quatf())
    @State private var cameraTrackingData = PositionAndOrientation(position: .zero, orientation: simd_quatf())
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
        // Track biplane model's position and orientation
        if let biplane = (arView.scene.anchors.first as? AnchorEntity)?.children.first as? ModelEntity {
            // Relative to world coordinates
            let newPosition = biplane.position(relativeTo: nil)
            let newOrientation = biplane.orientation(relativeTo: nil)
            
            // Update the tracking data
            $trackingData.wrappedValue.position = newPosition
            $trackingData.wrappedValue.orientation = newOrientation

            print("Biplane Position: \(newPosition)")
            print("Biplane Orientation: \(newOrientation)")
            self.saveTrackingData(type: "Biplane", position: newPosition, orientation: newOrientation)
        }

        if let cameraTransform = arView.session.currentFrame?.camera.transform {
            let cameraPosition = SIMD3<Float>(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
            let cameraOrientation = simd_quatf(cameraTransform)

            $cameraTrackingData.wrappedValue.position = cameraPosition
            $cameraTrackingData.wrappedValue.orientation = cameraOrientation

            print("Camera Position: \(cameraPosition)")
            print("Camera Orientation: \(cameraOrientation)")
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
            print("Saved \(type)_\(trackingData.timestamp)  successfully")
        } catch {
            print("Failed to save \(type)_\(trackingData.timestamp): \(error.localizedDescription)")
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}

struct PositionAndOrientation {
    var position: SIMD3<Float> // x, y, z coordinates
    var orientation: simd_quatf // Quaternion representing the orientation
}
