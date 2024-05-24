//
//  ScreenRecorder.swift
//  ARMotionCam
//
//  Created by 리아 on 5/6/24.
//

import Photos
import ReplayKit
import SwiftUI

class ScreenRecorder {
    private var recordInfo: RecordingInfo
    
    init(recordInfo: RecordingInfo) {
        self.recordInfo = recordInfo
    }
    
    func isRecording() -> Bool {
        return RPScreenRecorder.shared().isRecording
    }
    
    // Would be ideal to let the user know about this with an alert
    func startScreenRecording(_ completion: @escaping (Bool, Error?) -> Void) {
        if isRecording() {
            completion(false, RecordingError.duplicatedRecording)
        }
        if #available(iOS 15.0, *) {
            let clipURL = createDirectory()

            RPScreenRecorder.shared().startClipBuffering { [weak self] error in
                DispatchQueue.main.async {
                    if error == nil {
                        self?.recordInfo.currentURL = clipURL
                        self?.recordInfo.isRecording = true
                        completion(true, nil)
                    } else {
                        completion(false, RecordingError.recordFail(error))
                    }
                }
            }
        }
    }
    
    func stopAndExport(_ completion: @escaping (Bool, Error?) -> Void) {
        exportClip(at: recordInfo.currentURL) { [weak self] success, error in
            if error != nil {
                completion(false, error)
            }
            self?.stopScreenRecording(completion)
        }
    }
    
    func stopScreenRecording(_ completion: @escaping (Bool, Error?) -> Void) {
        if !isRecording() {
            completion(false, RecordingError.stopWithoutRecording)
            return
        }
        if #available(iOS 15.0, *) {
            RPScreenRecorder.shared().stopClipBuffering { [weak self] error in
                DispatchQueue.main.async {
                    if error == nil {
                        self?.recordInfo.isRecording = false
                        completion(true, nil)
                    } else {
                        completion(false, RecordingError.stopFail(error))
                    }
                }
            }
        }
    }
    
    func exportClip(at url: URL?, _ completion: @escaping (Bool, Error?) -> Void) {
        if !isRecording() {
            completion(false, RecordingError.exportWithoutBuffer)
            return
        }
        // internal for which the clip is to be extracted (Max: 15 sec)
        let interval = TimeInterval(15)
        
        if #available(iOS 15.0, *) {
            RPScreenRecorder.shared().exportClip(to: recordInfo.currentURL, duration: interval) { [weak self] error in
                if error == nil { self?.saveToPhotos(completion: completion) }
                else { completion(false, RecordingError.exportFail(error)) }
            }
        }
    }
    
    private func saveToPhotos(completion: @escaping (Bool, Error?) -> Void) {
            PHPhotoLibrary.shared().performChanges { [weak self] in
                let url = self?.recordInfo.currentURL ?? URL(fileURLWithPath: "")
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            } completionHandler: { [weak self] success, error in
                if success {
                    // Fetch the asset URL from the photo library
                    self?.fetchLastVideoURL { url in
                        DispatchQueue.main.async {
                            if let url = url {
                                self?.deleteTempFile()
                                self?.recordInfo.currentURL = url
                                completion(true, nil)
                            } else {
                                completion(false, RecordingError.saveFail(error))
                            }
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
    
    private func createDirectory() -> URL {
        var tempPath = URL(fileURLWithPath: NSTemporaryDirectory())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_hh-mm-ss"
        let stringDate = formatter.string(from: Date())
        tempPath.appendPathComponent(String.localizedStringWithFormat("ARVideo-%@.mp4", stringDate))
        return tempPath
    }
    
    private func deleteTempFile() {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: recordInfo.currentURL)
            print("Temporary file deleted: \(recordInfo.currentURL)")
        } catch {
            print("Failed to delete temporary file: \(error.localizedDescription)")
        }
    }
}
