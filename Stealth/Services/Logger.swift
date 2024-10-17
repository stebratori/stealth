//
//  Logger.swift
//  StealthAI
//
//  Created by Stefan Brankovic on 10/16/24.
//

import Foundation

class Logger {
    var log: [String] = []
    
    func log(message: String, from: String) {
        let logMessage: String = "[\(from)] \(message)"
        log.append(logMessage)
        print(logMessage)
    }
}
