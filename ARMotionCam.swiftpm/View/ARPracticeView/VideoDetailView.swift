//
//  VideoDetailView.swift
//  ARMotionCam
//
//  Created by 리아 on 5/24/24.
//

import SwiftUI
import AVKit

struct VideoDetailView: View {
    var video: ARVideo
    @Environment(\.managedObjectContext) private var viewContext
    @State private var spaceTimes: [SpaceTime] = []
    @State private var player: AVPlayer?
    @State private var playerLooper: AVPlayerLooper?
    
    var body: some View {
        HStack(spacing:0) {
            VStack(spacing:0) {
                if let videoUrlString = video.videoUrl, let videoUrl = URL(string: videoUrlString) {
                    VideoPlayer(player: player)
                        .onAppear {
                            fetchSpaceTimeData()
                            playVideo(of: videoUrl)
                        }
                        .disabled(true)
                } else {
                    Text("Invalid video URL")
                }
                
                if !spaceTimes.isEmpty {
                    ReconstructedSpaceView(spaceTimes: $spaceTimes)
                } else {
                    Text("Loading space data...")
                }
            }
            .ignoresSafeArea()
            ARPracticeCameraView(arVideo: video)
        }
    }
    
    private func playVideo(of videoUrl: URL) {
        let asset = AVAsset(url: videoUrl)
        let playerItem = AVPlayerItem(asset: asset)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        self.player = queuePlayer
        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        queuePlayer.play()
    }
    
    private func fetchSpaceTimeData() {
        spaceTimes = SpaceTimeDataManager.fetchSpaceTimeData(for: video, in: viewContext)
    }
}
