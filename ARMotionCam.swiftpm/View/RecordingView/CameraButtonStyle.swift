//
//  CameraButtonStyle.swift
//  ARMotionCam
//
//  Created by 리아 on 5/6/24.
//

import SwiftUI

struct CameraButtonnStyle: ButtonStyle {
    @EnvironmentObject var recordInfo: RecordingInfo
//    @Binding var isRecording: Bool
    var action: (() -> Void)?
    var innerCircleWidth: CGFloat {
        self.recordInfo.isRecording ? 32 : 49
    }
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 6)
                .foregroundColor(.red)
                .frame(width: 65, height: 65)

            RoundedRectangle(cornerRadius: recordInfo.isRecording ? 8 : innerCircleWidth / 2)
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

struct CameraButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        @State var isRecord = false
        Button(action: {}, label: {
            Text("Button")
        })
        .buttonStyle(CameraButtonnStyle())
    }
}
