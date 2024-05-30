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
    @ObservedObject var practiceInfo = PracticeInfo()
    var arVideo: ARVideo
    
    var body: some View {
        ZStack {
            ARPracticeViewContainer(practiceInfo: practiceInfo, arVideo: arVideo)
                .environment(\.managedObjectContext, viewContext)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("\(practiceInfo.currentDifference)")
                Text("\(practiceInfo.diffSum)")
            }
        }
    }
}
