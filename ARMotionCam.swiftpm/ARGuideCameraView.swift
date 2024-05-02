//
//  ARGuideCameraView.swift
//  ARMotionCam
//
//  Created by 리아 on 3/19/24.
//

import ARKit
import CoreData
import RealityKit
import SwiftUI

struct ARGuideCameraView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: TrackingData.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \TrackingData.timestamp, ascending: true)
        ],
        animation: .default)
    private var trackedData: FetchedResults<TrackingData>
    
    var body: some View {
        ZStack {
            ARViewContainer()
                .environment(\.managedObjectContext, viewContext)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("\(trackedData.suffix(2).first)")
                Text("\(trackedData.suffix(2).last)")
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Environment(\.managedObjectContext) private var viewContext
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        
        let coordinator = context.coordinator
        arView.session.delegate = coordinator
        coordinator.startTracking(in: arView)
        
        loadBiplaneModel(into: arView)
        animateBiplaneMovement(in: arView)
        
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
            entity.playAnimation(animation.repeat(duration: .infinity), 
                                 transitionDuration: animationTransitionDuration,
                                 startsPaused: false)
        }
    }
    
    private func animateBiplaneMovement(in arView: ARView) {
        guard let biplane = (arView.scene.anchors.first as? AnchorEntity)?.children.first as? ModelEntity else { return }
        
        let radius: Float = 1.0 // unit: meter
        let speed: Float = 0.01
        
        var angle: Float = 0.0
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            angle += speed
            let x = radius * sin(angle)
            let z = radius * cos(angle)
            let halfAngle = radius * Float.pi * 0.5
            
            biplane.transform.translation = [x, 0, z]
            biplane.transform.rotation = simd_quatf(angle: angle + halfAngle, axis: [0, 1, 0])
            
            // Stop the animation after completing n full circle
            let n: Float = 5.0
            if angle >= n * 2 * Float.pi * radius {
                timer.invalidate()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewContext)
    }
}

#Preview {
    ARGuideCameraView()
}
