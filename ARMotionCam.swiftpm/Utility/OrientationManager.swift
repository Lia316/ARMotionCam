//
//  OrientationManager.swift
//
//
//  Created by 리아 on 5/31/24.
//

import UIKit

class OrientationManager {
    static func forceLandscapeRight() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        
        let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscapeRight)
        scene.requestGeometryUpdate(geometryPreferences) { error in
            if let error = error as? NSError {
                print("Failed to update geometry: \(error.localizedDescription)")
            } else {
                print("Successfully updated geometry to landscape right.")
            }
        }
    }
}
