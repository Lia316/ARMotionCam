//
//  PracticeRecorderView.swift
//  ARMotionCam
//
//  Created by 리아 on 5/27/24.
//

import ARKit
import SwiftUI
import ARVideoKit

struct PracticeRecorderView: View {
    @ObservedObject var practiceInfo: PracticeInfo
    private var recorder: ScreenPracticeRecorder

    init(practiceInfo: PracticeInfo, arView: ARSCNView) {
        self.practiceInfo = practiceInfo
        self.recorder = ScreenPracticeRecorder(practiceInfo: practiceInfo, arView: arView)
    }
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: {}, label: {})
                .buttonStyle(CameraButtonnStyle2(practiceInfo: practiceInfo, action: { playOrPause() }))
        }
    }
    
    private func playOrPause() {
        if recorder.isRecording() {
            recorder.stopAndExport()
        } else {
            recorder.startScreenRecording()
        }
    }
}
