//
//  RecorderView.swift
//  ARMotionCam
//
//  Created by 리아 on 5/7/24.
//

import SwiftUI

struct RecorderView: View {
    private let recorder = ScreenRecorder()
    @Binding var isRecording: Bool
    @Binding var videoURL: URL?
    
    var body: some View {
        Button(action: {}, label: {})
            .buttonStyle(CameraButtonnStyle(
                isRecording: $isRecording,
                action: { playOrPause()})
            )
    }
    
    private func playOrPause() {
        if recorder.isRecording() {
            recorder.stopAndExport(at: videoURL) { success, error in
                isRecording = recorder.isRecording()
                if !success, let err = error as? RecordingError {
                    print("🔴", err.errorDescription)
                }
            }
        } else {
            recorder.startScreenRecording { clipURL, error in
                isRecording = recorder.isRecording()
                videoURL = clipURL
                if error != nil, let error = error as? RecordingError {
                    print("🔴",error)
                }
            }
        }
    }
    
}
