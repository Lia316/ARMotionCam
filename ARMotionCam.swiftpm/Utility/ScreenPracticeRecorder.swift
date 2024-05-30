//
//  ScreenPracticeRecorder.swift
//  ARMotionCam
//
//  Created by 리아 on 5/27/24.
//

import ARVideoKit
import ARKit
import Photos
import SwiftUI

class ScreenPracticeRecorder: NSObject, RecordARDelegate, RenderARDelegate {
    @ObservedObject private var practiceInfo: PracticeInfo
    private var recorder: RecordAR?
    private var arView: ARSCNView
    
    init(practiceInfo: PracticeInfo, arView: ARSCNView) {
        self.practiceInfo = practiceInfo
        self.arView = arView
        super.init()
        
        self.setupRecorder()
    }
    
    private func setupRecorder() {
        recorder = RecordAR(ARSceneKit: arView)
        recorder?.delegate = self
        recorder?.renderAR = self
        recorder?.onlyRenderWhileRecording = false
        recorder?.enableAdjustEnvironmentLighting = true
        recorder?.inputViewOrientations = [.landscapeLeft, .landscapeRight]
        recorder?.prepare()
    }
    
    func isRecording() -> Bool {
        practiceInfo.isRecording = recorder?.status == .recording
        return recorder?.status == .recording
    }
    
    func startScreenRecording() {
        guard recorder?.status == .readyToRecord else {
            print("Recording is already in progress or not ready to record.")
            return
        }
        
        print("Starting recording...")
        recorder?.record()
        DispatchQueue.main.async {
            self.practiceInfo.isRecording = true
        }
    }
    
    func stopAndExport() {
        guard isRecording() else {
            print("No recording in progress to stop.")
            DispatchQueue.main.async {
                self.practiceInfo.isRecording = false
            }
            return
        }
        
        print("Stopping and exporting recording...")
        recorder?.stopAndExport { [weak self] videoPath, permissionStatus, exported in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.practiceInfo.isRecording = false
                print("Recording stopped and exported. Path: \(videoPath.absoluteString), exported: \(exported)")
            }
        }
    }
    
    // RecordARDelegate methods
    func recorder(didEndRecording path: URL, with noError: Bool) {
        DispatchQueue.main.async {
            self.practiceInfo.isRecording = false
            print("Recording ended. Path: \(path.absoluteString), No error: \(noError)")
        }
    }
    
    func recorder(didFailRecording error: Error?, and status: String) {
        DispatchQueue.main.async {
            self.practiceInfo.isRecording = false
            print("Recording failed: \(String(describing: error)) - Status: \(status)")
        }
    }
    
    func recorder(willEnterBackground status: ARVideoKit.RecordARStatus) {
        DispatchQueue.main.async {
            self.practiceInfo.isRecording = false
            print("Recorder will enter background. Status: \(status)")
        }
    }
    
    // RenderARDelegate method
    func frame(didRender buffer: CVPixelBuffer, with time: CMTime, using rawBuffer: CVPixelBuffer) {}
    
    deinit {
        DispatchQueue.main.async {
            self.practiceInfo.isRecording = false
        }
        recorder?.stop()
        print("Recorder deinit")
    }
}
