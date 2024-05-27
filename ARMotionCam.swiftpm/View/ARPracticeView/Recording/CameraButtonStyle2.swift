//
//  CameraButtonStyle2.swift
//  ARMotionCam
//
//  Created by 리아 on 5/27/24.
//

import SwiftUI

//TODO: refactor - make screen recorder protocol & remove the file
struct CameraButtonnStyle2: ButtonStyle {
    var recorder: ScreenPracticeRecorder
    var action: (() -> Void)?
    var innerCircleWidth: CGFloat {
        self.recorder.isRecording() ? 32 : 49
    }
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 6)
                .foregroundColor(.red)
                .frame(width: 65, height: 65)

            RoundedRectangle(cornerRadius: recorder.isRecording() ? 8 : innerCircleWidth / 2)
                .foregroundColor(.red)
                .frame(width: innerCircleWidth, height: innerCircleWidth)

        }
        .padding(20)
        .onTapGesture {
            withAnimation {
                action?()
            }
        }
    }
}
