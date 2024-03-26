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
    @State private var trackingData = PositionAndOrientation(position: .zero, orientation: simd_quatf())
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        
        let coordinator = context.coordinator
        arView.session.delegate = coordinator
        coordinator.startTracking(in: arView)
        
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
    
    func makeCoordinator() -> Coordinator {
        Coordinator($trackingData)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
            var trackingData: Binding<PositionAndOrientation>
            var timer: Timer?

            init(_ trackingData: Binding<PositionAndOrientation>) {
                self.trackingData = trackingData
            }

            func startTracking(in arView: ARView) {
                timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
                    self?.updateTrackingData(arView: arView)
                }
            }

            private func updateTrackingData(arView: ARView) {
                if let anchor = arView.scene.anchors.first as? AnchorEntity {
                    let newPosition = anchor.position
                    let newOrientation = anchor.orientation
                    
                    // Update the tracking data
                    trackingData.wrappedValue.position = newPosition
                    trackingData.wrappedValue.orientation = newOrientation

                    // Print the updated data to the console
                    print("Position: \(newPosition)")
                    print("Orientation: \(newOrientation)")
                }
            }

            deinit {
                timer?.invalidate()
            }
        }
}

#Preview {
    ARGuideCameraView()
}

struct PositionAndOrientation {
    var position: SIMD3<Float> // x, y, z coordinates
    var orientation: simd_quatf // Quaternion representing the orientation
}

