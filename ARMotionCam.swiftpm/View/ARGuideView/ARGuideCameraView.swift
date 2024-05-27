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
    
    var body: some View {
        ZStack {
            ARViewContainer()
                .environment(\.managedObjectContext, viewContext)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    ARGuideCameraView()
}
