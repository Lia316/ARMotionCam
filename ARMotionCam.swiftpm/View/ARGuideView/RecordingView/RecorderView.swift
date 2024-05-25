//
//  RecorderView.swift
//  ARMotionCam
//
//  Created by 리아 on 5/7/24.
//

import SwiftUI

struct RecorderView: View {
    @EnvironmentObject var recordInfo: RecordingInfo
    private var recorder: ScreenRecorder

    init(recordInfo: RecordingInfo) {
        self.recorder = ScreenRecorder(recordInfo: recordInfo)
    }
    
    var body: some View {
        Button(action: {}, label: {})
            .buttonStyle(CameraButtonnStyle(action: { playOrPause()}))
    }
    
    private func playOrPause() {
        if recorder.isRecording() {
            recorder.stopAndExport() { success, error in
                recordInfo.isRecording = recorder.isRecording()
                if !success, let err = error as? RecordingError {
                    print("🔴", err.errorDescription)
                }
            }
        } else {
            recorder.startScreenRecording { clipURL, error in
                recordInfo.isRecording = recorder.isRecording()
                if error != nil, let error = error as? RecordingError {
                    print("🔴",error)
                }
            }
        }
    }
    
}
