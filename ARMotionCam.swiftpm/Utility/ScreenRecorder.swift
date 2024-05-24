//
//  ScreenRecorder.swift
//  ARMotionCam
//
//  Created by 리아 on 5/6/24.
//
/* ***************************************************
*
*    Title: RollingClipProj/ViewController.swift
*    Author: Sandeep Kumar
*    Date: 16/10/21
*    Availability: https://github.com/mrSandeepKr/RollingClipProj/tree/main
*
*****************************************************/

import Photos
import ReplayKit
import SwiftUI

enum RecordingError: Error, LocalizedError {
    case duplicatedRecording
    case stopWithoutRecording
    case exportWithoutBuffer
    case recordFail(Error?)
    case stopFail(Error?)
    case exportFail(Error?)
    case saveFail(Error?)

    public var errorDescription: String {
        switch self {
        case .duplicatedRecording:
            return "Attempting To start recording while recording is in progress"
        case .stopWithoutRecording:
            return "Attempting the stop recording without an on going recording session"
        case .exportWithoutBuffer:
            return "Attemping to export clip while rolling clip buffer is turned off"
        case .recordFail(let error):
            return "Error Occured trying to start rolling clip: \(String(describing: error))"
        case .stopFail(let error):
            return "Failed to stop screen recording: \(String(describing: error))"
        case .exportFail(let error):
            return "Error attempting export clip: \(String(describing: error))"
        case .saveFail(let error):
            return "Error exporting clip to Photos: \(String(describing: error))"
        }
    }
}

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
        } completionHandler: { success, error in
            if success { completion(true, nil) }
            else { completion(false, RecordingError.saveFail(error)) }
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
    
}
