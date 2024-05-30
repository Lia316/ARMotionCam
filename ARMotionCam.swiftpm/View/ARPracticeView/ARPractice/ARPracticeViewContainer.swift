//
//  ARPracticeViewContainer.swift
//  ARMotionCam
//
//  Created by 리아 on 5/27/24.
//

import ARKit
import SceneKit
import SwiftUI

struct ARPracticeViewContainer: UIViewRepresentable {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var practiceInfo: PracticeInfo
    var arVideo: ARVideo

    func makeUIView(context: Context) -> UIView {
        let sceneView = ARSCNView()
        let container = setup(context, sceneView)
        
        loadBiplaneModel(in: sceneView)
        context.coordinator.startTracking(in: sceneView)
                
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let sceneView = uiView.subviews.first(where: { $0 is ARSCNView }) as? ARSCNView {
            context.coordinator.startTracking(in: sceneView)
        }
    }
    
    func makeCoordinator() -> ARPracticeTrackingCoordinator {
        ARPracticeTrackingCoordinator(viewContext, practiceInfo: practiceInfo, guideData: arVideo)
    }
    
    private func setup(_ context: Context, _ sceneView: ARSCNView) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        
        sceneView.delegate = context.coordinator
        sceneView.autoenablesDefaultLighting = true
        sceneView.frame = container.bounds
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
        
        let recorderView = UIHostingController(rootView: PracticeRecorderView(practiceInfo: practiceInfo, arView: sceneView).environmentObject(practiceInfo)).view
        recorderView?.frame = container.bounds
        recorderView?.backgroundColor = .clear
        recorderView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        container.addSubview(sceneView)
        container.addSubview(recorderView!)
        
        return container
    }
    
    private func loadBiplaneModel(in sceneView: ARSCNView) {
        let scene = SCNScene(named: "toy_biplane_idle.usdz")
        let node = scene?.rootNode.childNodes.first ?? SCNNode()
        node.name = "model"
        node.scale = SCNVector3(0.01, 0.01, 0.01)  // Scale the biplane model
        sceneView.scene.rootNode.addChildNode(node)
    }
}
