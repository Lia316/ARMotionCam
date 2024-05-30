//
//  ARPracticeCameraView.swift
//  ARMotionCam
//
//  Created by 리아 on 3/19/24.
//

import SwiftUI
import CoreData
import AVKit

struct ARPracticeCameraView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var practiceInfo = PracticeInfo()
    var arVideo: ARVideo
    
    var body: some View {
        ZStack {
            ARPracticeViewContainer(arVideo: arVideo)
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(practiceInfo)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("Current Difference: \(practiceInfo.currentDifference, specifier: "%.4f")")
                Text("Difference Avg: \(practiceInfo.avgDifference, specifier: "%.4f")")
            }
        }
        .onAppear {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
        .onDisappear {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
}
