//
//  iPSService.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 31/05/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import Moya

/// Declares the available endpoints for the GitHub service.
enum iPSService {
    
    case videos
    
    static var host: String {
        return "iphonephotographyschool.com"
    }
}

// MARK: - Adopts TargetType for Moya integration
extension iPSService: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://\(iPSService.host)/test-api")!
    }
    
    var path: String {
        switch self {
        case .videos:
            return "/videos"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .videos:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .videos:
            return .requestPlain
        }
    }
    
    var sampleData: Data {
        switch self {
        case .videos:
            return "[]".data(using: .utf8)!
        }
    }
    
    var headers: [String: String]? {
        return [:]
    }
}

