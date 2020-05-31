//
//  VideoDetailViewModel.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 31/05/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import Foundation

class VideoDetailViewModel: ObservableObject, Identifiable {
    private let video: Video
    
    init(video: Video) {
        self.video = video
    }
    
    var title: String {
        return video.name
    }
    
    var description: String {
        return video.description
    }
    
    func playVideo() {
        
    }
}

