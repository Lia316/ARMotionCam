//
//  ARViewContainer.swift
//  
//
//  Created by 리아 on 5/7/24.
//

import ARKit
import SceneKit
import SwiftUI
import ARVideoKit

struct ARViewContainer: UIViewRepresentable {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var recordInfo: RecordingInfo

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        
        let sceneView = ARSCNView()
        sceneView.delegate = context.coordinator
        sceneView.autoenablesDefaultLighting = true
        sceneView.frame = container.bounds
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Add AR Configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
        
        container.addSubview(sceneView)
        
        // Initialize the ScreenRecorder with ARSCNView
        context.coordinator.screenRecorder = ScreenRecorder(recordInfo: recordInfo, arView: sceneView)
        
        // Load and animate the model
        loadBiplaneModel(in: sceneView)
        animateBiplaneMovement(in: sceneView)
        context.coordinator.startTracking(in: sceneView)
        
        // Add RecorderView as a subview
        let recorderView = UIHostingController(rootView: RecorderView(recordInfo: recordInfo, arView: sceneView)).view
        recorderView?.frame = container.bounds
        recorderView?.backgroundColor = .clear
        recorderView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(recorderView!)
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let sceneView = uiView.subviews.first(where: { $0 is ARSCNView }) as? ARSCNView {
            context.coordinator.startTracking(in: sceneView)
        }
    }
    
    func makeCoordinator() -> ARTrackingCoordinator {
        ARTrackingCoordinator(viewContext, recordInfo: recordInfo)
    }
    
    private func loadBiplaneModel(in sceneView: ARSCNView) {
        let scene = SCNScene(named: "toy_biplane_idle.usdz")
        let node = scene?.rootNode.childNodes.first ?? SCNNode()
        node.name = "model"
        node.scale = SCNVector3(0.01, 0.01, 0.01)  // Scale the biplane model
        sceneView.scene.rootNode.addChildNode(node)
    }

    private func animateBiplaneMovement(in sceneView: ARSCNView) {
        guard let biplane = sceneView.scene.rootNode.childNode(withName: "model", recursively: true) else { return }
        
        let radius: Float = 1.0 // unit: meter
        let speed: Float = 0.01
        
        var angle: Float = 0.0
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            angle += speed
            let x = radius * sin(angle)
            let z = radius * cos(angle)
            
            let halfAngle = angle + Float.pi / 2
            
            biplane.position = SCNVector3(x, 0, z)
            biplane.eulerAngles = SCNVector3(0, halfAngle, 0)
            
            // Stop the animation after completing n full circles
            let n: Float = 5.0
            if angle >= n * 2 * Float.pi * radius {
                timer.invalidate()
            }
        }
    }
}
