//
//  VideoDetailViewModelSpec.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 03/06/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import XCTest
import Quick
import Nimble
import OHHTTPStubs
import Moya
import AVKit
@testable import iPSChallenge

class VideoDetailViewModelSpec: QuickSpec {        

    override func spec() {
        
        describe("detail view model") {
            
            var viewModel: VideoDetailViewModel!
            var manager: MockPersistenceManager!
            var asset: Asset!
            var successPlayback: [MockPersistenceManager.StreamState]!
            var failurePlayback: [MockPersistenceManager.StreamState]!
            
            beforeEach {
                manager = MockPersistenceManager()
                asset = Asset(id: "1", urlAsset: AVURLAsset(url: Video.dummy.videoLink))
                manager.asset = asset
                manager.downloadState = .notDownloaded
                viewModel = VideoDetailViewModel(video: .dummy, manager: manager)
                
                successPlayback = [
                    (name: .assetDownloadStateChangedNotification,
                     userInfo: [Asset.Keys.id: asset.id,
                                Asset.Keys.downloadState: Asset.DownloadState.downloading]),
                    (name: .assetDownloadProgressNotification,
                     userInfo: [Asset.Keys.id: asset.id,
                                Asset.Keys.percentDownloaded: 0.25]),
                    (name: .assetDownloadProgressNotification,
                     userInfo: [Asset.Keys.id: asset.id,
                                Asset.Keys.percentDownloaded: 0.75]),
                    (name: .assetDownloadProgressNotification,
                     userInfo: [Asset.Keys.id: asset.id,
                                Asset.Keys.percentDownloaded: 1.0]),
                    (name: .assetDownloadStateChangedNotification,
                     userInfo: [Asset.Keys.id: asset.id,
                                Asset.Keys.downloadState: Asset.DownloadState.downloaded])
                ]
                
                failurePlayback = [
                    (name: .assetDownloadStateChangedNotification,
                     userInfo: [Asset.Keys.id: asset.id,
                                Asset.Keys.downloadState: Asset.DownloadState.downloading]),
                    (name: .assetDownloadStateChangedNotification,
                     userInfo: [Asset.Keys.id: asset.id,
                                Asset.Keys.error: "Error downloading data",
                                Asset.Keys.downloadState: Asset.DownloadState.notDownloaded])
                ]
            }
            
            it("has a title") {
                expect(viewModel.title) == Video.dummy.name
            }
            
            it("has a description") {
                expect(viewModel.description) == Video.dummy.description
            }
            
            it("has a thumb URL") {
                expect(viewModel.thumbnail) == Video.dummy.thumbnail
            }
            
            it("has a stream URL") {
                expect(viewModel.videoLink) == Video.dummy.videoLink
            }
            
            context("interacting with the persistence manager") {
                
                it("should be unavailable until restoration finishes") {
                    expect(viewModel.downloadAvailable) == false
                    manager.makeAvailable()
                    expect(viewModel.downloadAvailable).toEventually(beTrue())
                }
                
                context("querying asset download states") {
                    
                    it("should reflect notDownloaded state") {
                        manager.downloadState = .notDownloaded
                        manager.postDownloadState()
                        expect(viewModel.downloadState).toEventually(equal(.notDownloaded))
                    }
                    
                    it("should reflect downloading state") {
                        manager.downloadState = .downloading
                        manager.postDownloadState()
                        expect(viewModel.downloadState.isDownloading).toEventually(beTrue())
                    }
                    
                    it("should reflect downloaded state") {
                        manager.downloadState = .downloaded
                        manager.postDownloadState()
                        expect(viewModel.downloadState).toEventually(equal(.downloaded))
                    }
                }
                
                it("has a fully completed download") {
                    manager.streamPlayback = successPlayback
                    viewModel.downloadVideo()
                    manager.downloadState = .notDownloaded
                    expect(viewModel.downloadState).toEventually(equal(.downloaded))
                }
                
                it("has a download in progress") {
                    manager.streamPlayback = successPlayback.dropLast(2)
                    viewModel.downloadVideo()
                    expect(viewModel.downloadState) == .notDownloaded
                    expect(viewModel.downloadState.isDownloading).toEventually(beTrue())
                    expect(viewModel.progress) == 0.75
                }
                
                it("has a failed download") {
                    manager.streamPlayback = failurePlayback
                    viewModel.downloadVideo()
                    expect(viewModel.downloadState) == .notDownloaded
                    expect(viewModel.hasError) == false
                    expect(viewModel.hasError).toEventually(beTrue())
                    expect(viewModel.downloadState).toEventually(equal(.notDownloaded))
                }
                
                it("can delete a downloaded video") {
                    manager.streamPlayback = successPlayback
                    viewModel.downloadVideo()
                    expect(viewModel.downloadState).toEventually(equal(.downloaded))
                    viewModel.removeVideo()
                    expect(viewModel.downloadState).toEventually(equal(.notDownloaded))
                }
                
                it("can cancel a download inflight") {
                    manager.streamPlayback = successPlayback.dropLast(2)
                    viewModel.downloadVideo()
                    expect(viewModel.progress).toEventually(equal(0.75))
                    viewModel.cancelDownload()
                    expect(viewModel.downloadState).toEventually(equal(.notDownloaded))
                }
                
                it("only updates state for a matching asset id") {
                    manager.streamPlayback = [
                        (name: .assetDownloadStateChangedNotification,
                         userInfo: [Asset.Keys.id: "49",
                                    Asset.Keys.downloadState: Asset.DownloadState.downloading])
                    ]
                    viewModel.downloadVideo()
                    manager.downloadState = .notDownloaded
                    expect(viewModel.downloadState).toEventually(equal(.notDownloaded))
                }
                
                context("when receiving malformed notifications") {
                    
                }
                it("doesn't update state with a malformed notification") {
                    manager.streamPlayback = [
                        (name: .assetDownloadStateChangedNotification,
                         userInfo: [Asset.Keys.id: asset.id,
                                    Asset.Keys.downloadState: Asset.DownloadState.downloading]),
                        (name: .assetDownloadStateChangedNotification,
                         userInfo: [Asset.Keys.id: asset.id,
                                    Asset.Keys.error: "Error downloading data",
                                    Asset.Keys.downloadState: Asset.DownloadState.notDownloaded])
                    ]
                }
            }
        }
        
    }

}
