//
//  VideoListViewModelSpec.swift
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
@testable import iPSChallenge

class VideoListViewModelSpec: QuickSpec {
    
    override func spec() {
        
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
            beforeEach {
                stub(condition: isHost(iPSService.host)) { _ in
                    return HTTPStubsResponse(data: "{\"videos\":[]}".data(using: .utf8)!,
                                             statusCode: 200,
                                             headers: nil)
                }
                viewModel = VideoListViewModel()
            }
            
            it("should start uninitialized") {
                expect(viewModel.state) == .uninitialized
            }
            
            it("should change to ready after fetching data") {
                viewModel.fetchVideos()
                expect(viewModel.state).toEventually(equal(.ready([])))
            }
            
            context("when there is a server error") {
                
                let error = "Localized error message from any thrown error"
                beforeEach {
                    stub(condition: isHost(iPSService.host)) { _ in
                        return HTTPStubsResponse(error: error)
                    }
                    viewModel = VideoListViewModel()
                }
                
                it("should change to error state") {
                    viewModel.fetchVideos()
                    expect(viewModel.state.error).toEventuallyNot(beNil())
                }
            }
            
            context("when server sends unparsable data") {
                
                beforeEach {
                    stub(condition: isHost(iPSService.host)) { _ in
                        return HTTPStubsResponse(data: Data(),
                                                 statusCode: 200,
                                                 headers: nil)
                    }
                    viewModel = VideoListViewModel()
                }
                
                it("should change to error state") {
                    viewModel.fetchVideos()
                    expect(viewModel.state.error).toEventuallyNot(beNil())
                }
            }
        }
    }

}
