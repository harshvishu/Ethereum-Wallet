//
//  StringExtensions.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/16/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import Foundation

enum RexPatterns: String{
    case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//    case integers = "^[0-9]*$"
}

extension String{
    
    func matches(rex: RexPatterns) -> Bool{
        return matches(pattern: rex.rawValue)
    }
    
    func matches(pattern: String) -> Bool{
        let predicate = NSPredicate(format: "SELF MATCHES%@", pattern)
        
        return predicate.evaluate(with: self)
    }
}

let DATE_FORMAT_VERBOSE = "EEE, d MMM yyyy h:mm a"

extension Date{
    func readable() -> String{
        let format = DateFormatter()
        format.dateFormat = DATE_FORMAT_VERBOSE
        return format.string(from: self)
    }
}
