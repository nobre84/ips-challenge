//
//  Video.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 31/05/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import Foundation

struct Video: Codable, Equatable {
    let id: Int
    let name: String
    let thumbnail: URL
    let description: String
    let videoLink: URL

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case thumbnail
        case description
        case videoLink = "video_link"
    }
}
