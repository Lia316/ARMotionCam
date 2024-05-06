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
                RecorderView()
            }
        }
    }
}

#Preview {
    ARGuideCameraView()
}
