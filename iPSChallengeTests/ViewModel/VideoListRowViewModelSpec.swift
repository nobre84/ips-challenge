//
//  VideoListRowViewModelSpec.swift
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

class VideoListRowViewModelSpec: QuickSpec {

    override func spec() {
        
        describe("row view model") {
            
            var viewModel: VideoListRowViewModel!
            
            beforeEach {
                viewModel = VideoListRowViewModel(video: .dummy)
            }
            
            afterEach {
                Locale.resetLocale()
                Bundle.resetLanguage()
            }
            
            it("has a title") {
                expect(viewModel.title) == Video.dummy.name
            }
            
            it("has a description") {
                expect(viewModel.subtitle) == Video.dummy.description
            }
            
            it("has a thumbnail") {
                expect(viewModel.thumbnail) == Video.dummy.thumbnail
            }
            
        }
    }
    
}
