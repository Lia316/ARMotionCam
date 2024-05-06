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

class ScreenRecorder {
    
    func startScreenRecording() {
        if isRecording() {
            print("Attempting To start recording while recording is in progress")
            return
        }
        if #available(iOS 15.0, *) {
            RPScreenRecorder.shared().startClipBuffering { err in
                if err != nil {
                    print("Error Occured trying to start rolling clip: \(String(describing: err))")
                    //Would be ideal to let the user know about this with an alert
                }
                print("Rolling Clip started successfully")
            }
        }
    }
    
    func stopScreenRecording() {
        if !isRecording() {
            print("Attempting the stop recording without an on going recording session")
            return
        }
        if #available(iOS 15.0, *) {
            RPScreenRecorder.shared().stopClipBuffering { err in
                if err != nil {
                    print("Failed to stop screen recording")
                    // Would be ideal to let user know about this with an alert
                }
                print("Rolling Clip stopped successfully")
            }
        }
    }
    
    func exportClip() {
        if !isRecording() {
            print("Attemping to export clip while rolling clip buffer is turned off")
            return
        }
        // internal for which the clip is to be extracted
        // Max Value: 15 sec
        let interval = TimeInterval(15)
        
        let clipURL = getDirectory()
        
        print("Generating clip at URL: ", clipURL)
        if #available(iOS 15.0, *) {
            RPScreenRecorder.shared().exportClip(to: clipURL, duration: interval) { [weak self] error in
                if error != nil {
                    print("Error attempting export clip")
                    // would be ideal to show an alert letting user know about the failure
                }
                self?.saveToPhotos(tempURL: clipURL)
            }
        }
    }
    
    private func isRecording() -> Bool {
        return RPScreenRecorder.shared().isRecording
    }
    
    private func getDirectory() -> URL {
        var tempPath = URL(fileURLWithPath: NSTemporaryDirectory())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_hh-mm-ss"
        let stringDate = formatter.string(from: Date())
        tempPath.appendPathComponent(String.localizedStringWithFormat("ARVide-%@.mp4", stringDate))
        return tempPath
    }
    
    private func saveToPhotos(tempURL: URL) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: tempURL)
        } completionHandler: { success, error in
            if success == true {
                print("Saved rolling clip to photos")
            } else {
                print("Error exporting clip to Photos \(String(describing: error))")
            }
        }
    }
}
