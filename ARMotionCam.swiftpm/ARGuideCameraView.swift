//
//  ARGuideCameraView.swift
//  ARMotionCam
//
//  Created by 리아 on 3/19/24.
//

import SwiftUI
import RealityKit
import ARKit
import CoreData

struct ARGuideCameraView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        ARViewContainer()
            .environment(\.managedObjectContext, viewContext)
            .edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Environment(\.managedObjectContext) private var viewContext
//    @FetchRequest(
//        entity: TrackingData.entity(),
//        sortDescriptors: [
//            NSSortDescriptor(keyPath: \TrackingData.timestamp, ascending: true)
//        ],
//        animation: .default)
//    private var trackedData: FetchedResults<TrackingData>
    
    @State private var trackingData = PositionAndOrientation(position: .zero, orientation: simd_quatf())
    @State private var cameraTrackingData = PositionAndOrientation(position: .zero, orientation: simd_quatf())
    
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
            entity.playAnimation(animation.repeat(duration: .infinity), transitionDuration: animationTransitionDuration, startsPaused: false)
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
        Coordinator(viewContext, $trackingData, $cameraTrackingData)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        private var viewContext: NSManagedObjectContext
        var trackingData: Binding<PositionAndOrientation>
        var cameraTrackingData: Binding<PositionAndOrientation>
        var timer: Timer?
        
        init(_ viewContext: NSManagedObjectContext, _ trackingData: Binding<PositionAndOrientation>, _ cameraTrackingData: Binding<PositionAndOrientation>) {
            self.viewContext = viewContext
            self.trackingData = trackingData
            self.cameraTrackingData = cameraTrackingData
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
                trackingData.wrappedValue.position = newPosition
                trackingData.wrappedValue.orientation = newOrientation

                print("Biplane Position: \(newPosition)")
                print("Biplane Orientation: \(newOrientation)")
                self.saveTrackingData(type: "Biplane", position: newPosition, orientation: newOrientation)
            }

            if let cameraTransform = arView.session.currentFrame?.camera.transform {
                let cameraPosition = SIMD3<Float>(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
                let cameraOrientation = simd_quatf(cameraTransform)

                cameraTrackingData.wrappedValue.position = cameraPosition
                cameraTrackingData.wrappedValue.orientation = cameraOrientation

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
}

#Preview {
    ARGuideCameraView()
}

struct PositionAndOrientation {
    var position: SIMD3<Float> // x, y, z coordinates
    var orientation: simd_quatf // Quaternion representing the orientation
}

