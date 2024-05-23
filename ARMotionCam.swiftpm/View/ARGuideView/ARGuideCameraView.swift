//
//  ARGuideCameraView.swift
//  ARMotionCam
//
//  Created by 리아 on 3/19/24.
//

import CoreData
import SwiftUI

struct ARGuideCameraView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isRecording = false
    @State private var videoURL: URL?
    @FetchRequest(
        entity: ARVideo.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ARVideo.videoUrl, ascending: true)
        ],
        animation: .default)
    private var trackedData: FetchedResults<ARVideo>
    
    var body: some View {
        ZStack {
            ARViewContainer(isRecording: $isRecording, videoURL: $videoURL)
                .environment(\.managedObjectContext, viewContext)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("\(trackedData.count)")
                Text("\(trackedData.suffix(2).first)")
                Text("\(trackedData.suffix(2).last)")
                RecorderView(isRecording: $isRecording, videoURL: $videoURL)
            }
        }
    }
}

#Preview {
    ARGuideCameraView()
}
