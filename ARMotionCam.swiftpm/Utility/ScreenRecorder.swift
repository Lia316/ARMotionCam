//
//  ScreenRecorder.swift
//  ARMotionCam
//
//  Created by 리아 on 5/6/24.
//

import ARVideoKit
import ARKit
import Photos
import SwiftUI

class ScreenRecorder: NSObject, RecordARDelegate, RenderARDelegate {
    private var recordInfo: RecordingInfo
    private var recorder: RecordAR?
    
    init(recordInfo: RecordingInfo, arView: ARSCNView) {
        self.recordInfo = recordInfo
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
            self.recordInfo.isRecording = self.isRecording()
        }
    }
    
    func stopAndExport() {
        recorder?.stopAndExport() { videoPath, permissionStatus, exported in
            self.fetchLastVideoURL {  newURL in
                DispatchQueue.main.async {
                    if let newURL = newURL {
                        self.recordInfo.currentURL = newURL
                    }
                }
            }
            DispatchQueue.main.async {
                self.recordInfo.isRecording = self.isRecording()
            }
        }
    }
    
    private func fetchLastVideoURL(completion: @escaping (URL?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1

        let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)

        if let lastAsset = fetchResult.firstObject {
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true

            PHImageManager.default().requestAVAsset(forVideo: lastAsset, options: options) { (asset, _, _) in
                if let urlAsset = asset as? AVURLAsset {
                    completion(urlAsset.url)
                } else {
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }
    
    // RecordARDelegate methods
    func recorder(didEndRecording path: URL, with noError: Bool) {}
    func recorder(didFailRecording error: Error?, and status: String) {}
    func recorder(willEnterBackground status: ARVideoKit.RecordARStatus) {}
    
    // RenderARDelegate method
    func frame(didRender buffer: CVPixelBuffer, with time: CMTime, using rawBuffer: CVPixelBuffer) {}
}
