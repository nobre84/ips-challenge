//
//  String+LocalizedError.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 02/06/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import Foundation

extension String: LocalizedError {
    
    public var errorDescription: String? {
        return self
    }
    
}
