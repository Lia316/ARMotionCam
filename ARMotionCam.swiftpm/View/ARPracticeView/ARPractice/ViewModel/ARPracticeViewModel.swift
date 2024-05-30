//
//  ARPracticeViewModel.swift
//  ARMotionCam
//
//  Created by 리아 on 5/27/24.
//

import Foundation

class PracticeInfo: ObservableObject {
    @Published var isRecording = false
    @Published var currentDifference: Double = 0.0
    @Published var diffSum: Double = 0.0
}
