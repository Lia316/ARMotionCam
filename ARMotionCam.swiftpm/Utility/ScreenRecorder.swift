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

import ReplayKit
import Photos

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
    // Would be ideal to let the user know about this with an alert
    func startScreenRecording(_ completion: @escaping (URL?, Error?) -> Void) {
        if isRecording() {
            completion(nil, RecordingError.duplicatedRecording)
        }
        if #available(iOS 15.0, *) {
            let clipURL = createDirectory()

            RPScreenRecorder.shared().startClipBuffering { error in
                if error == nil {
                    completion(clipURL, nil)
                } else {
                    completion(nil, RecordingError.recordFail(error))
                }
            }
        }
    }
    
    func stopAndExport(at url: URL?,_ completion: @escaping (Bool, Error?) -> Void) {
        exportClip(at: url) { [weak self] success, error in
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
            RPScreenRecorder.shared().stopClipBuffering { error in
                if error == nil { completion(true, nil) }
                else { completion(false, RecordingError.stopFail(error)) }
            }
        }
    }
    
    func exportClip(at url: URL?, _ completion: @escaping (Bool, Error?) -> Void) {
        if !isRecording() {
            completion(false, RecordingError.exportWithoutBuffer)
            return
        }
        guard let url = url else {
            completion(false, RecordingError.exportFail(nil))
            return
        }
        // internal for which the clip is to be extracted (Max: 15 sec)
        let interval = TimeInterval(15)
        
        if #available(iOS 15.0, *) {
            RPScreenRecorder.shared().exportClip(to: url, duration: interval) { [weak self] error in
                if error == nil { self?.saveToPhotos(tempURL: url, completion: completion) }
                else { completion(false, RecordingError.exportFail(error)) }
            }
        }
    }
    
    func isRecording() -> Bool {
        return RPScreenRecorder.shared().isRecording
    }
    
    private func createDirectory() -> URL {
        var tempPath = URL(fileURLWithPath: NSTemporaryDirectory())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_hh-mm-ss"
        let stringDate = formatter.string(from: Date())
        tempPath.appendPathComponent(String.localizedStringWithFormat("ARVideo-%@.mp4", stringDate))
        return tempPath
    }
    
    private func saveToPhotos(tempURL: URL, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: tempURL)
        } completionHandler: { success, error in
            if success { completion(true, nil) }
            else { completion(false, RecordingError.saveFail(error)) }
        }
    }
}
