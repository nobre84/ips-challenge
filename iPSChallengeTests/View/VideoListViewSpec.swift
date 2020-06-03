//
//  VideoListViewSpec.swift
//  iPSChallengeTests
//
//  Created by Rafael Nobre on 03/06/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import XCTest
import Quick
import Nimble
import ViewInspector
import SwiftUI
import AVKit
import OHHTTPStubs
@testable import iPSChallenge

class VideoListViewSpec: QuickSpec {

    override func spec() {
        
        describe("list view") {
            
            beforeEach {
                HTTPStubs.onStubActivation { request, stub, _ in
                    print("Stubbing \(request) with \(stub)")
                }
            }
            
            afterEach {
                HTTPStubs.removeAllStubs()
            }
            
            describe("state") {
                var viewModel: VideoListViewModel!
                var view: VideoListView!
                beforeEach {
                    stub(condition: isHost(iPSService.host)) { _ in
                        return HTTPStubsResponse(data: "{\"videos\":[]}".data(using: .utf8)!,
                                                 statusCode: 200,
                                                 headers: nil)
                    }
                    viewModel = VideoListViewModel()
                    view = VideoListView(viewModel: viewModel)
                }
                
                afterEach {
                    Bundle.resetLanguage()
                }
                
                it("should show activity indicator when uninitialized") {
                    expect {
                        try view.body.inspect().anyView().vStack().view(ActivityIndicator.self, 0)
                    }.notTo(throwError())
                }
                
                it("should show empty message in english") {
                    Bundle.forceLanguage("en")
                    viewModel.fetchVideos()
                    expect(viewModel.state.isLoading).toEventually(beFalse())
                    expect {
                        try view.body.inspect().anyView().vStack().text(1).string() == "No videos"
                    }.notTo(throwError())
                }
                
                it("should show empty message in brazilian portuguese") {
                    Bundle.forceLanguage("pt-BR")
                    viewModel.fetchVideos()
                    expect(viewModel.state.isLoading).toEventually(beFalse())
                    expect {
                        try view.body.inspect().anyView().vStack().text(1).string() == "Nenhum vídeo"
                    }.notTo(throwError())
                }
                
                it("should show a list with videos") {
                    stub(condition: isHost(iPSService.host)) { _ in
                        let data = try! JSONEncoder().encode(VideoListResponse.dummy)
                        return HTTPStubsResponse(data: data,
                                                 statusCode: 200,
                                                 headers: nil)
                    }
                    
                    viewModel.fetchVideos()
                    expect(viewModel.state.isLoading).toEventually(beFalse())
                    
                    expect {
                        try view.body.inspect().anyView().list()
                    }.notTo(throwError())
                }
                
            }
            
        }
        
    }
}

extension ActivityIndicator: Inspectable { }

extension VideoListResponse {
    static var dummy: Self {
        return VideoListResponse(videos: [.dummy])
    }
}
