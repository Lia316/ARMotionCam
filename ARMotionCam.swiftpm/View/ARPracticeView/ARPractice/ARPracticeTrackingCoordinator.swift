//
//  ARPracticeTrackingCoordinator.swift
//  ARMotionCam
//
//  Created by 리아 on 5/27/24.
//

import ARKit
import CoreData
import SceneKit
import SwiftUI

class ARPracticeTrackingCoordinator: NSObject, ARSessionDelegate, ARSCNViewDelegate {
    
    enum AnimationState {
        case playing
        case stopped
        case ready
    }
    
    private var viewContext: NSManagedObjectContext
    @ObservedObject var practiceInfo: PracticeInfo
    private var cameraSpaceTime: [SpaceTime]
    private var modelSpaceTime: [SpaceTime]

    private var currentCameraIndex = 0
    private var currentModelIndex = 0
    private var animationState = AnimationState.stopped
    private var posAniPlayer: SCNAnimationPlayer?
    private var oriAniPlayer: SCNAnimationPlayer?
    private var timer: Timer?
    
    init(_ viewContext: NSManagedObjectContext, practiceInfo: PracticeInfo, guideData: ARVideo) {
        self.viewContext = viewContext
        self._practiceInfo = ObservedObject(wrappedValue: practiceInfo)
        self.cameraSpaceTime = SpaceTimeDataManager.fetchCameraData(for: guideData, in: viewContext)
        self.modelSpaceTime = SpaceTimeDataManager.fetchModelData(for: guideData, in: viewContext)
    }
    
    func startTracking(in arView: ARSCNView) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            self?.update(arView)
        }
    }
    
    func stopTracking() {
        timer?.invalidate()
        timer = nil
        animationState = .stopped
        posAniPlayer?.stop()
        oriAniPlayer?.stop()
    }
    
    private func update(_ arView: ARSCNView) {
        guard practiceInfo.isRecording else {
            stopTracking()
            return
        }
        updateTrackingData(arView: arView)
        animateModel()
    }
    
    private func animateModel() {
        if currentModelIndex < modelSpaceTime.count {
            currentModelIndex += 1
        } else {
            currentModelIndex = 0
        }
        updateAnimationState(to: animationState)
    }
    
    func registerModelAnimation(in arView: ARSCNView) {
        guard let modelNode = arView.scene.rootNode.childNode(withName: "model", recursively: true) else { return }
        let modelDuration = CFTimeInterval(modelSpaceTime.count) * 0.3

        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        positionAnimation.values = modelSpaceTime.map { NSValue(scnVector3: SCNVector3($0.positionX, $0.positionY, $0.positionZ)) }
        positionAnimation.duration = modelDuration
        positionAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        positionAnimation.repeatCount = .greatestFiniteMagnitude

        let orientationAnimation = CAKeyframeAnimation(keyPath: "orientation")
        orientationAnimation.values = modelSpaceTime.map { NSValue(scnVector4: SCNVector4($0.orientationX, $0.orientationY, $0.orientationZ, $0.orientationW)) }
        orientationAnimation.duration = modelDuration
        orientationAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        orientationAnimation.repeatCount = .greatestFiniteMagnitude
        
        modelNode.addAnimation(positionAnimation, forKey: "position")
        modelNode.addAnimation(orientationAnimation, forKey: "orientation")
        
        posAniPlayer = modelNode.animationPlayer(forKey: "position")
        oriAniPlayer = modelNode.animationPlayer(forKey: "orientation")
        
        updateAnimationState(to: .stopped)
    }
    
    private func updateAnimationState(to state: AnimationState) {
        guard let positionPlayer = posAniPlayer, let orientationPlayer = oriAniPlayer else { return }
        
        switch state {
        case .playing:
            break
        case .stopped:
            positionPlayer.stop()
            orientationPlayer.stop()
            animationState = .ready
        case .ready:
            positionPlayer.play()
            orientationPlayer.play()
            animationState = .playing
        }
    }
    
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
            
            let totalDifference = Double(positionDifference + orientationDifference)
            let n = Double(currentCameraIndex)
            let prevDiffRatio = Double(n / (n + 1.0))
            let currDiffRatio = Double(1.0 / (n + 1.0))
            let prevDifference = prevDiffRatio * self.practiceInfo.avgDifference
            
            // Update practiceInfo
            DispatchQueue.main.async {
                self.practiceInfo.currentDifference = totalDifference
                self.practiceInfo.avgDifference = prevDifference + totalDifference * currDiffRatio
            }
            
            currentCameraIndex += 1
        } else {
            // Reset tracking
            currentCameraIndex = 0
        }
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
