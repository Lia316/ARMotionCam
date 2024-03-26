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

        // Load the model
        let anchor = AnchorEntity()
        do {
            let biplane = try ModelEntity.loadModel(named: "toy_biplane_idle.usdz")
            anchor.addChild(biplane)
        } catch {
            print("Error loading model: \(error)")
        }
        arView.scene.addAnchor(anchor)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

#Preview {
    ARGuideCameraView()
}
