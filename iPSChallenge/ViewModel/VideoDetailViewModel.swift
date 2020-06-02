//
//  VideoDetailViewModel.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 31/05/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import Foundation
import AVFoundation
import Combine

class VideoDetailViewModel: ObservableObject, Identifiable {
    
    enum DownloadState {
        case notDownloaded
        case downloading(Double)
        case downloaded
        
        var isDownloaded: Bool {
            if case .downloaded = self {
                return true
            }
            return false
        }
        
        var isDownloading: Bool {
            if case .downloading = self {
                return true
            }
            return false
        }
        
        static func fromAssetState(_ assetState: Asset.DownloadState) -> Self {
            switch assetState {
                case .notDownloaded:
                    return .notDownloaded
            case .downloading:
                return .downloading(0)
            case .downloaded:
                return .downloaded
            }
        }
    }
    
    private let video: Video
    private let asset: Asset
    private let manager: AssetPersistenceManager
    private var disposables = Set<AnyCancellable>()
    
    @Published var downloadState: DownloadState {
        didSet {
            if case .downloading(let progress) = downloadState {
                self.progress = progress
            }
        }
    }
    @Published var progress: Double = 0
    @Published var hasError = false
    @Published var downloadAvailable = false
    var errorMessage: String?
    
    init(video: Video, manager: AssetPersistenceManager = .sharedManager) {
        self.video = video
        self.asset = manager.assetFor(id: "\(video.id)", url: video.videoLink)
        self.manager = manager
        self.downloadState = .fromAssetState(manager.downloadState(for: self.asset))
        self.downloadAvailable = manager.isAvailable
        
        // Download State updates
        NotificationCenter.default.publisher(for: .assetDownloadStateChangedNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let userInfo = notification.userInfo else { return }
                // Mismatched or missing id
                guard let id = userInfo[Asset.Keys.id] as? String,
                    id == self?.asset.id else {
                    return
                }
                // Unknown or missing state
                guard let state = userInfo[Asset.Keys.downloadState] as? Asset.DownloadState else {
                    return
                }
                // Update state
                self?.downloadState = .fromAssetState(state)
                
                let error = userInfo[Asset.Keys.error] as? Error
                self?.hasError = error != nil
                self?.errorMessage = error?.localizedDescription
                Log.debug("State change: \(String(describing: self?.downloadState)) with error \(String(describing: error))")
        }
        .store(in: &disposables)
        
        // Download Progress updates
        NotificationCenter.default.publisher(for: .assetDownloadProgressNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let userInfo = notification.userInfo else { return }
                // Mismatched or missing id
                guard let id = userInfo[Asset.Keys.id] as? String,
                    id == self?.asset.id else {
                    return
                }
                // Unknown or missing state
                guard let progress = notification.userInfo?[Asset.Keys.percentDownloaded] as? Double else {
                    return
                }
                // Update state
                self?.downloadState = .downloading(progress)
                
                Log.debug("Progress change: \(String(describing: self?.downloadState))")
        }
        .store(in: &disposables)
        
        // Manager restoration completed
        NotificationCenter.default.publisher(for: .assetPersistenceManagerDidRestoreStateNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.downloadAvailable = true
                
                Log.debug("Download manager is available")
        }
        .store(in: &disposables)
    }
    
    var title: String {
        return video.name
    }
    
    var description: String {
        return video.description
    }
    
    var thumbnail: URL {
        return video.thumbnail
    }
    
    var videoLink: URL {
        return asset.urlAsset.url
    }
    
    func downloadVideo() {        
        manager.downloadStream(for: asset)
    }
    
    func removeVideo() {
        manager.deleteAsset(asset)
    }
    
    func cancelDownload() {
        manager.cancelDownload(for: asset)
    }
}

