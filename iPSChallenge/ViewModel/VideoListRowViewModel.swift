//
//  VideoListRowViewModel.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 31/05/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import Foundation

class VideoListRowViewModel: ObservableObject, Identifiable {
    private let video: Video
    
    init(video: Video) {
        self.video = video
    }
    
    var title: String {
        return video.name
    }
    
    var thumbnail: URL {
        return video.thumbnail
    }
    
    var subtitle: String {
        return video.description
    }
    
    var detailViewModel: VideoDetailViewModel {
        return VideoDetailViewModel(video: video)
    }
}

extension VideoListRowViewModel: Equatable {
    
    static func == (lhs: VideoListRowViewModel, rhs: VideoListRowViewModel) -> Bool {
        return lhs.video == rhs.video
    }
        
}

