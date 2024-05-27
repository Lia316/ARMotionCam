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
    private var practiceInfo: PracticeInfo
    private var recorder: RecordAR?
    
    init(practiceInfo: PracticeInfo, arView: ARSCNView) {
        self.practiceInfo = practiceInfo
        super.init()
        
        recorder = RecordAR(ARSceneKit: arView)
        recorder?.delegate = self
        recorder?.renderAR = self
        recorder?.onlyRenderWhileRecording = false
        recorder?.enableAdjustEnvironmentLighting = true
        recorder?.inputViewOrientations = [.landscapeLeft, .landscapeRight]
        recorder?.prepare()
    }
    
    func isRecording() -> Bool {
        return recorder?.status == .recording
    }
    
    func startScreenRecording() {
        recorder?.record()
        DispatchQueue.main.async {
            self.practiceInfo.isRecording = self.isRecording()
        }
    }
    
    func stopAndExport() {
        recorder?.stopAndExport() { [weak self] videoPath, permissionStatus, exported in
            guard let self = self else { return }
            self.saveToPhotos(url: videoPath) { success, error in
                DispatchQueue.main.async {
                    self.practiceInfo.isRecording = self.isRecording()
                }
            }
        }
    }
    
    private func saveToPhotos(url: URL, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        } completionHandler: { success, error in
            completion(success, error)
        }
    }
    
    // RecordARDelegate methods
    func recorder(didEndRecording path: URL, with noError: Bool) {}
    func recorder(didFailRecording error: Error?, and status: String) {}
    func recorder(willEnterBackground status: ARVideoKit.RecordARStatus) {}
    
    // RenderARDelegate method
    func frame(didRender buffer: CVPixelBuffer, with time: CMTime, using rawBuffer: CVPixelBuffer) {}
}
