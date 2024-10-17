//
//  Extensions+String.swift
//  StealthAI
//
//  Created by Stefan Brankovic on 10/14/24.
//

import Foundation

extension [String] {
    func toString() -> String {
        var returnString: String = ""
        for string in self {
            returnString += "\(string), "
        }
        return returnString
    }
}
