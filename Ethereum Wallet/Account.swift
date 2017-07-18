//
//  Account.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/18/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import Foundation

struct Account: ResponseObjectSerializable {
    
    var id: String
    var updatedAt: String
    var createdAt: String
    var xpub: String
    var user: String
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String : Any],
            let id = parseString(representation, param: "_id"),
            let updatedAt = parseString(representation, param: "updatedAt"),
            let createdAt = parseString(representation, param: "createdAt"),
            let xpub = parseString(representation, param: "xpub"),
            let user = parseString(representation, param: "user")
            
            else {return nil}
        
        self.id = id
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        self.xpub = xpub
        self.user = user
    }
}
