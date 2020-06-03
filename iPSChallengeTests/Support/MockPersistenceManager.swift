//
//  MockPersistenceManager.swift
//  iPSChallengeTests
//
//  Created by Rafael Nobre on 03/06/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import Foundation
import Combine
@testable import iPSChallenge

final class MockPersistenceManager: AssetPersistence {
        
    typealias StreamState = (name: Notification.Name, userInfo: [Asset.Keys: Any])
    
    /// Mocked values
    var asset: Asset?
    var downloadState: Asset.DownloadState?
    var streamPlayback: [StreamState]?
    
    private var cancellable: AnyCancellable?
    
    /// AssetPersistence API
    
    var isAvailable: Bool = false
        
    func assetFor(id: String, url: URL) -> Asset {
        guard let asset = asset else {
            fatalError("asset should be mocked prior to calling assetFor(id:url:)")
        }
        return asset
    }
    
    func downloadState(for asset: Asset) -> Asset.DownloadState {
        guard let downloadState = downloadState else {
            fatalError("downloadState should be mocked prior to calling downloadState(for:)")
        }
        return downloadState
    }
    
    func downloadStream(for asset: Asset) {
        guard let streamPlayback = streamPlayback else {
            fatalError("streamPlayback should be mocked prior to calling downloadStream(for:)")
        }
        
        let subject = PassthroughSubject<StreamState, Never>()
        
        cancellable = subject
            .delay(for: .milliseconds(10), scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] streamState in
                print("Received value in subject: \(streamState)")
                self?.postUpdate(streamState.userInfo,
                                 forName: streamState.name)
            })
        
        streamPlayback.forEach { subject.send($0) }
    }
    
    func cancelDownload(for asset: Asset) {
        cancellable?.cancel()
        postUpdate([Asset.Keys.id: asset.id,
                    Asset.Keys.downloadState: Asset.DownloadState.notDownloaded],
                   forName: .assetDownloadStateChangedNotification)
    }
    
    func deleteAsset(_ asset: Asset) {
        postUpdate([Asset.Keys.id: asset.id,
                    Asset.Keys.downloadState: Asset.DownloadState.notDownloaded],
                   forName: .assetDownloadStateChangedNotification)
    }
    
    func makeAvailable() {
        isAvailable = true
        postUpdate([:], forName: .assetPersistenceManagerDidRestoreStateNotification)
    }
    
    func postDownloadState() {
        guard let downloadState = downloadState else {
            fatalError("downloadState should be mocked prior to calling postDownloadState()")
        }
        guard let asset = asset else {
            fatalError("asset should be mocked prior to calling postDownloadState()")
        }
        postUpdate([Asset.Keys.id: asset.id,
                    Asset.Keys.downloadState: Asset.DownloadState(rawValue: downloadState.rawValue)!],
        forName: .assetDownloadStateChangedNotification)
    }
    
}
