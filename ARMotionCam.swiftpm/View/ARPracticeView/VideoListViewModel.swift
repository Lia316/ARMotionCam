//
//  VideoListViewModel.swift
//
//
//  Created by 리아 on 5/24/24.
//

import Foundation
import CoreData
import AVKit
import SwiftUI

class VideoListViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var videos: [ARVideo] = []
    private var context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<ARVideo>
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        let fetchRequest: NSFetchRequest<ARVideo> = ARVideo.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ARVideo.createdAt, ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        self.fetchedResultsController.delegate = self
        fetchVideos()
    }
    
    func fetchVideos() {
        do {
            try fetchedResultsController.performFetch()
            videos = fetchedResultsController.fetchedObjects ?? []
        } catch {
            print("Failed to fetch videos: \(error.localizedDescription)")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let updatedVideos = controller.fetchedObjects as? [ARVideo] else { return }
        videos = updatedVideos
    }
    
    func getThumbnail(from url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteVideo(_ video: ARVideo) {
        withAnimation {
            context.delete(video)
            do {
                try context.save()
            } catch {
                print("Failed to delete video: \(error.localizedDescription)")
            }
        }
    }
}
