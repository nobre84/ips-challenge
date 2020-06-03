//
//  iPSServiceSpec.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 03/06/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import XCTest
import Quick
import Nimble
import Moya
@testable import iPSChallenge

class iPSServiceSpec: QuickSpec {
    
    override func spec() {
        
        describe("ips service") {
            
            context("host") {
                it("points to the correct host") {
                    let service = iPSService.videos
                    expect(service.baseURL.host) == "iphonephotographyschool.com"
                }
            }
            
            context("path generation") {
                
                it("generates videos path") {
                    let service = iPSService.videos
                    expect(service.path) == "/videos"
                }
            }                        
        }
    }
    
}
