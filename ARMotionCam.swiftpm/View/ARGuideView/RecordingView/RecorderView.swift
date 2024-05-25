//
//  RecorderView.swift
//  ARMotionCam
//
//  Created by 리아 on 5/7/24.
//

import ARKit
import SwiftUI
import ARVideoKit

struct RecorderView: View {
    @EnvironmentObject var recordInfo: RecordingInfo
    private var recorder: ScreenRecorder

    init(recordInfo: RecordingInfo, arView: ARSCNView) {
        self.recorder = ScreenRecorder(recordInfo: recordInfo, arView: arView)
    }
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: {}, label: {})
                .buttonStyle(CameraButtonnStyle(action: { playOrPause() }))
        }
    }
    
    private func playOrPause() {
        if recorder.isRecording() {
            recorder.stopAndExport { success, error in
                recordInfo.isRecording = recorder.isRecording()
                if !success, let err = error as? RecordingError {
                    print("🔴", err.errorDescription)
                }
            }
        } else {
            recorder.startScreenRecording { success, error in
                recordInfo.isRecording = recorder.isRecording()
                if !success, let error = error as? RecordingError {
                    print("🔴", error)
                }
            }
        }
    }
}
