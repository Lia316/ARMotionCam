//
//  ARGuideViewModel.swift
//  ARMotionCam
//
//  Created by 리아 on 5/24/24.
//

import Foundation

class RecordingInfo: ObservableObject {
    @Published var isRecording = false
    @Published var currentURL = URL(fileURLWithPath: "")
}
