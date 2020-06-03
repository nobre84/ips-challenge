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
@testable import iPSChallenge

class VideoDetailViewModelSpec: QuickSpec {        

    override func spec() {
        
        describe("detail view model") {
            
            var viewModel: VideoDetailViewModel!
            var manager: AssetPersistence!
            
            beforeEach {
                manager = MockPersistenceManager()
                viewModel = VideoDetailViewModel(video: .dummy/*, manager: manager*/)
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
                
            }
        }
        
    }

}
