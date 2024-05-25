//
//  ARPracticeCameraView.swift
//  ARMotionCam
//
//  Created by 리아 on 3/19/24.
//

import SwiftUI
import CoreData
import AVKit

struct VideoListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = VideoListViewModel(context: Persistence.shared.container.viewContext)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                ForEach(viewModel.videos, id: \.self) { video in
                    if let videoUrl = video.videoUrl, let url = URL(string: videoUrl) {
                        VStack {
                            if let thumbnail = viewModel.getThumbnail(from: url) {
                                NavigationLink(destination: VideoDetailView(video: video)) {
                                    Image(uiImage: thumbnail)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 150)
                                        .clipped()
                                }
                            } else {
                                Color.gray
                                    .frame(width: 150, height: 150)
                            }
                            Text(video.createdAt?.formatted() ?? "Unknown Date")
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.deleteVideo(video)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchVideos()
        }
        .navigationTitle("Videos")
    }
}
