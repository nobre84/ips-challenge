//
//  Video+Dummy.swift
//  iPSChallengeTests
//
//  Created by Rafael Nobre on 03/06/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import Foundation
@testable import iPSChallenge

extension Video {
    static var dummy: Self {
        return Video(id: 95,
                     name: "How to hold the iPhone camera steady",
                     thumbnail: URL(string: "https://i.picsum.photos/id/254/2000/2000.jpg")!,
                     description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
                     videoLink: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
    }
}

