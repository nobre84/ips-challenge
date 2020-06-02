//
//  Log.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 02/06/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import Foundation

public class Log {
    
    // MARK: - Public Methods
    
    public static func debug(_ message: String, tag: String = "") {
        #if DEBUG
            log(type: "DEBUG", message: message, tag: tag)
        #endif
    }
    
    public static func warning(_ message: String, tag: String = "") {
        #if DEBUG
            log(type: "WARNING", message: message, tag: tag)
        #endif
    }
    
    public static func error(_ message: String, tag: String = "") {
        log(type: "ERROR", message: message, tag: tag)
    }
    
    // MARK: - Private Methods
    
    private static func log(type: String, message: String, tag: String) {
        let tag = !tag.isEmpty ? "\(tag), " : ""
        print("\(type): \(tag)\(message)")
    }

}
