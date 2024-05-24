//
//  RecordingError.swift
//  
//
//  Created by 리아 on 5/24/24.
//

import Foundation

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
