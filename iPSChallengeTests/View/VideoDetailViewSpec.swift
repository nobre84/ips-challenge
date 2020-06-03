//
//  VideoDetailViewSpec.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 03/06/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import XCTest
import Quick
import Nimble
import ViewInspector
@testable import iPSChallenge

class VideoDetailViewSpec: QuickSpec {

    override func spec() {
        
        describe("detail view") {
            
            var detailView: VideoDetailView!
            var viewModel: VideoDetailViewModel!
            var manager: MockPersistenceManager!
            
            beforeEach {
                manager = MockPersistenceManager()
                viewModel = VideoDetailViewModel(video: .dummy, manager: manager)
                detailView = VideoDetailView(viewModel: viewModel)
            }
            
        }
        
    }
}
