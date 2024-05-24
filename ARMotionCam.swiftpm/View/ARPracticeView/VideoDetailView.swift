//
//  VideoDetailView.swift
//  
//
//  Created by 리아 on 5/24/24.
//

import SwiftUI
import AVKit

struct VideoDetailView: View {
    var video: ARVideo
    
    @State private var player: AVPlayer?
    @State private var playerLooper: AVPlayerLooper?
    
    var body: some View {
        VStack {
            if let videoUrlString = video.videoUrl, let videoUrl = URL(string: videoUrlString) {
                VideoPlayer(player: player)
                    .onAppear {
                        let asset = AVAsset(url: videoUrl)
                        let playerItem = AVPlayerItem(asset: asset)
                        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
                        self.player = queuePlayer
                        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
                        queuePlayer.play()
                    }
                    .frame(height: 300)
                    .disabled(true) // Disable the video controller
                Text(video.createdAt?.formatted() ?? "Unknown Date")
                    .padding()
                // Add any other views you want here
            } else {
                Text("Invalid video URL")
            }
        }
        .navigationTitle("Video Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
