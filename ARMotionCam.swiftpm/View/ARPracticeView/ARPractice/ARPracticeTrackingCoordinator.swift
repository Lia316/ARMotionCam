//
//  ARPracticeTrackingCoordinator.swift
//  ARMotionCam
//
//  Created by 리아 on 5/27/24.
//

import ARKit
import CoreData
import RealityKit
import SceneKit
import SwiftUI

class ARPracticeTrackingCoordinator: NSObject, ARSessionDelegate, ARSCNViewDelegate {
    
    enum TrackingType: String {
        case camera = "Camera"
        case model = "Model"
    }
    
    private var viewContext: NSManagedObjectContext
    @ObservedObject var practiceInfo: PracticeInfo
    private var cameraSpaceTime: [SpaceTime]
    private var modelSpaceTime: [SpaceTime]
    
    private var lastModelPosition: SCNVector3?
    private var lastModelOrientation: SCNVector4?
    private var lastCameraPosition: SIMD3<Float>?
    private var lastCameraOrientation: simd_quatf?
    private var currentCameraIndex = 0
    private var currentModelIndex = 0
    var timer: Timer?
    
    init(_ viewContext: NSManagedObjectContext, practiceInfo: PracticeInfo, guideData: ARVideo) {
        self.viewContext = viewContext
        self._practiceInfo = ObservedObject(wrappedValue: practiceInfo)
        self.cameraSpaceTime = SpaceTimeDataManager.fetchCameraData(for: guideData, in: viewContext)
        self.modelSpaceTime = SpaceTimeDataManager.fetchModelData(for: guideData, in: viewContext)
    }
    
    func startTracking(in arView: ARSCNView) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.practiceInfo.isRecording {
                self.updateTrackingData(arView: arView)
                self.animateModel(in: arView)
            } else {
                self.stopTracking()
            }
        }
    }
    
    private func stopTracking() {
        timer?.invalidate()
    }
    
    // Animate the model using fetched data
    private func animateModel(in arView: ARSCNView) {
        guard let modelNode = arView.scene.rootNode.childNode(withName: "model", recursively: true) else { return }
        
        if currentModelIndex < modelSpaceTime.count {
            let modelData = modelSpaceTime[currentModelIndex]
            modelNode.position = SCNVector3(modelData.positionX, modelData.positionY, modelData.positionZ)
            modelNode.orientation = SCNVector4(modelData.orientationX, modelData.orientationY, modelData.orientationZ, modelData.orientationW)
            currentModelIndex += 1
        } else {
            // Reset animation
            currentModelIndex = 0
        }
    }
    
    // Update current difference & difference sum in PracticeInfo
    private func updateTrackingData(arView: ARSCNView) {
        guard let currentFrame = arView.session.currentFrame else { return }
        
        let cameraTransform = currentFrame.camera.transform
        let cameraPosition = SIMD3<Float>(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
        let cameraOrientation = simd_quatf(cameraTransform)
        
        if currentCameraIndex < cameraSpaceTime.count {
            let guideData = cameraSpaceTime[currentCameraIndex]
            let guidePosition = SIMD3<Float>(guideData.positionX, guideData.positionY, guideData.positionZ)
            let guideOrientation = simd_quatf(vector: SIMD4<Float>(guideData.orientationX, guideData.orientationY, guideData.orientationZ, guideData.orientationW))
            
            // Calculate differences
            let positionDifference = distance(cameraPosition, guidePosition)
            let orientationDifference = distance(cameraOrientation.vector, guideOrientation.vector)
            
            // Update practiceInfo
            let totalDifference = Double(positionDifference + orientationDifference)
            DispatchQueue.main.async {
                self.practiceInfo.currentDifference = totalDifference
                self.practiceInfo.diffSum += totalDifference
            }
            
            currentCameraIndex += 1
        } else {
            // Reset tracking
            currentCameraIndex = 0
        }
        
        lastCameraPosition = cameraPosition
        lastCameraOrientation = cameraOrientation
    }

    private func distance(_ vectorA: SIMD3<Float>, _ vectorB: SIMD3<Float>) -> Float {
        return simd_distance(vectorA, vectorB)
    }

    private func distance(_ vectorA: SIMD4<Float>, _ vectorB: SIMD4<Float>) -> Float {
        return simd_distance(vectorA, vectorB)
    }
    
    deinit {
        stopTracking()
    }
}
