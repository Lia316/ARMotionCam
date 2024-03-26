//
//  ARGuideCameraView.swift
//  ARMotionCam
//
//  Created by 리아 on 3/19/24.
//

import SwiftUI
import RealityKit
import ARKit

struct ARGuideCameraView: View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        loadBiplaneModel(into: arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}

    private func loadBiplaneModel(into arView: ARView) {
        let anchor = AnchorEntity()
        
        if let biplane = try? ModelEntity.loadModel(named: "toy_biplane_idle.usdz") {
            anchor.addChild(biplane)
            playAnimations(for: biplane)
        } else {
            print("Error loading the biplane model")
        }
        
        arView.scene.addAnchor(anchor)
    }

    private func playAnimations(for entity: ModelEntity) {
        let animationTransitionDuration: TimeInterval = 1.25
        for animation in entity.availableAnimations {
            entity.playAnimation(animation.repeat(duration: .infinity), transitionDuration: animationTransitionDuration, startsPaused: false)
        }
    }
}

#Preview {
    ARGuideCameraView()
}
