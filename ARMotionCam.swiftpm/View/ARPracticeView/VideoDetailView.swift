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
    @Environment(\.managedObjectContext) private var viewContext
    @State private var spaceTimes: [SpaceTime] = []
    @State private var player: AVPlayer?
    @State private var playerLooper: AVPlayerLooper?
    
    var body: some View {
        HStack {
            VStack {
                if let videoUrlString = video.videoUrl, let videoUrl = URL(string: videoUrlString) {
                    VideoPlayer(player: player)
                        .onAppear {
                            fetchSpaceTimeData()
                            playVideo(of: videoUrl)
                        }
                        .frame(height: 300)
                        .disabled(true)
                    Text(video.createdAt?.formatted() ?? "Unknown Date")
                        .padding()
                } else {
                    Text("Invalid video URL")
                }
                
                if !spaceTimes.isEmpty {
                    ReconstructedSpaceView(spaceTimes: $spaceTimes)
                        .frame(height: 300)
//                        .aspectRatio(1.0, contentMode: .fit)
//                        .padding()
                } else {
                    Text("Loading space data...")
                        .frame(height: 300)
                }
            }
            Text("Additional Information")
                .font(.title)
                .padding()
        }
        .navigationTitle("Video Detail")
        .navigationBarTitleDisplayMode(.inline)
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
