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
    @EnvironmentObject var recordInfo: RecordingInfo

    @FetchRequest(
        entity: ARVideo.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ARVideo.videoUrl, ascending: true)
        ],
        animation: .default)
    private var trackedData: FetchedResults<ARVideo>
    
    var body: some View {
        ZStack {
            ARViewContainer()
                .environment(\.managedObjectContext, viewContext)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("\(trackedData.count)")
                Text("\(String(describing: trackedData.last))")
                if let carr = trackedData.last?.cameraInfoArray.last, let marr = trackedData.last?.modelInfoArray.last {
                    Text("\(carr.stringForDebug())")
                    Text("\(marr.stringForDebug())")
                }
            }
        }
    }
}

#Preview {
    ARGuideCameraView()
}
