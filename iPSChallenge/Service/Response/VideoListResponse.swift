//
//  VideoListResponse.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 31/05/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import Foundation

struct VideoListResponse: Decodable {
    let videos: [Video]
}
