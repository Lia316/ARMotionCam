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
        recorder?.prepare()
    }
    
    func isRecording() -> Bool {
        return recorder?.status == .recording
    }
    
    func startScreenRecording(_ completion: @escaping (Bool, Error?) -> Void) {
        if isRecording() {
            completion(false, RecordingError.duplicatedRecording)
            return
        }
        recorder?.record(forDuration: 0.5) { [weak self] videoPath in
            guard let self = self else { return }
            self.recordInfo.isRecording = true
            self.recordInfo.currentURL = videoPath
            completion(true, nil)

        }
    }
    
    func stopAndExport(_ completion: @escaping (Bool, Error?) -> Void) {
        if !isRecording() {
            completion(false, RecordingError.stopWithoutRecording)
            return
        }
        
        recorder?.stop() { url in
            self.recordInfo.currentURL = url
            self.saveToPhotos(url: url, completion: completion)
        }
    }
    
    private func saveToPhotos(url: URL, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        } completionHandler: { success, error in
            if success {
                self.deleteTempFile(url: url)
                self.fetchLastVideoURL { newURL in
                    if let newURL = newURL {
                        self.recordInfo.currentURL = newURL
                        completion(true, nil)
                    } else {
                        completion(false, RecordingError.saveFail(error))
                    }
                }
            } else {
                completion(false, RecordingError.saveFail(error))
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
    
    private func deleteTempFile(url: URL) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: url)
            print("Temporary file deleted: \(url)")
        } catch {
            print("Failed to delete temporary file: \(error.localizedDescription)")
        }
    }
    
    // RecordARDelegate methods
    func recorder(didEndRecording path: URL, with noError: Bool) {}
    func recorder(didFailRecording error: Error?, and status: String) {}
    func recorder(willEnterBackground status: ARVideoKit.RecordARStatus) {}
    
    // RenderARDelegate method
    func frame(didRender buffer: CVPixelBuffer, with time: CMTime, using rawBuffer: CVPixelBuffer) {}
}
