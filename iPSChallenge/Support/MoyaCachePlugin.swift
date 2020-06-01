//
//  MoyaCachePlugin.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 01/06/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import Foundation
import Moya

protocol MoyaCacheable {
    var cachePolicy: URLRequest.CachePolicy { get }
}

final class MoyaCachePlugin: PluginType {

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        if let cacheableTarget = target as? MoyaCacheable {
            var mutableRequest = request
            mutableRequest.cachePolicy = cacheableTarget.cachePolicy
            return mutableRequest
        }
        return request
    }
}
