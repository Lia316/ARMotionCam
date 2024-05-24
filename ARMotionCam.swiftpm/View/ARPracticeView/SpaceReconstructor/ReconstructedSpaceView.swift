//
//  ReconstructedSpaceView.swift
//
//
//  Created by 리아 on 5/24/24.
//

import SwiftUI
import SceneKit

struct ReconstructedSpaceView: UIViewRepresentable {
    @Binding var spaceTimes: [SpaceTime]
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = SCNScene()
        sceneView.allowsCameraControl = false  // Disable user interaction
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = UIColor.black

        // Setup initial scene
        setupScene(sceneView.scene!, sceneView: sceneView)

        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Clear previous animations and nodes
        uiView.scene?.rootNode.childNodes.forEach { $0.removeFromParentNode() }
        setupScene(uiView.scene!, sceneView: uiView)
    }

    private func setupScene(_ scene: SCNScene, sceneView: SCNView) {
        // Separate spaceTimes for model and camera
        let modelSpaceTimes = spaceTimes.filter { $0.modelInfoOrigin != nil }
        let cameraSpaceTimes = spaceTimes.filter { $0.cameraInfoOrigin != nil }
        
        // Calculate space volume
        let volume = spaceTimes.calculateSpaceVolume()
        
        // Create and add model node
        let modelNode = createModelNode()
        scene.rootNode.addChildNode(modelNode)

        // Create and add camera node
        let cameraNode = createCameraNode()
        scene.rootNode.addChildNode(cameraNode)

        // Set up the main camera
        setupMainCamera(scene: scene, volume: volume)
        
        // Add ambient light to the scene
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 1000
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)

        // Animate model and camera
        animateNodes(modelNode: modelNode, cameraNode: cameraNode, modelSpaceTimes: modelSpaceTimes, cameraSpaceTimes: cameraSpaceTimes, volume: volume)
    }
    
    private func createModelNode() -> SCNNode {
        let node = SCNNode()
        // Load your model here, e.g., SCNScene(named: "your_model.scn")?.rootNode
        node.geometry = SCNSphere(radius: 0.1) // Placeholder geometry
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        return node
    }
    
    private func createCameraNode() -> SCNNode {
        let node = SCNNode()
        // Placeholder geometry for visualization
        node.geometry = SCNSphere(radius: 0.05)
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        return node
    }

    private func setupMainCamera(scene: SCNScene, volume: SpaceVolume) {
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        scene.rootNode.addChildNode(cameraNode)
        
        // Position the camera to view the entire scene
        let midX = (volume.minX + volume.maxX) / 2
        let midY = (volume.minY + volume.maxY) / 2
        let midZ = (volume.minZ + volume.maxZ) / 2
        let maxDimension = max(volume.maxX - volume.minX, volume.maxY - volume.minY, volume.maxZ - volume.minZ)
        
        cameraNode.position = SCNVector3(midX, midY, midZ + maxDimension * 2)
        cameraNode.look(at: SCNVector3(midX, midY, midZ))
    }

    private func animateNodes(modelNode: SCNNode, cameraNode: SCNNode, modelSpaceTimes: [SpaceTime], cameraSpaceTimes: [SpaceTime], volume: SpaceVolume) {
        print("🔴 model Space&Time Tracking", modelSpaceTimes.map{$0.stringForDebug()})
        print("🔴 camera Space&Time Tracking", cameraSpaceTimes.map{$0.stringForDebug()})
        let modelDuration = CFTimeInterval(modelSpaceTimes.count) * 0.3
        let cameraDuration = CFTimeInterval(cameraSpaceTimes.count) * 0.3
        
        let modelAnimation = CAKeyframeAnimation(keyPath: "position")
        modelAnimation.values = modelSpaceTimes.map { NSValue(scnVector3: SCNVector3($0.positionX, $0.positionY, $0.positionZ)) }
        modelAnimation.duration = modelDuration
        modelAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        modelAnimation.repeatCount = .infinity
        
        let cameraAnimation = CAKeyframeAnimation(keyPath: "position")
        cameraAnimation.values = cameraSpaceTimes.map { NSValue(scnVector3: SCNVector3($0.positionX, $0.positionY, $0.positionZ)) }
        cameraAnimation.duration = cameraDuration
        cameraAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        cameraAnimation.repeatCount = .infinity
        
        modelNode.addAnimation(modelAnimation, forKey: "modelAnimation")
        cameraNode.addAnimation(cameraAnimation, forKey: "cameraAnimation")
    }
}
