//
//  WalletResponse.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/17/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import Foundation

struct WalletResponse: ResponseObjectSerializable {
    var name: String?
    var statusCode: Int?
    
    var error: WalletResponseError?
    var response: WalletResponseMeta?
    
    var account: Account?
    var balance: String?
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String : Any]
            else {return nil}
        
        name = parseString(representation, param: "name")
        statusCode = parseInt(representation, param: "statusCode")
        
        // balance & id
        if let account = parseDict(representation, param: "account"){
            self.account = Account(response: response, representation: account)
        }
        
        self.balance = parseString(representation, param: "balance")
        
        
        if let error = parseDict(representation, param: "error"){
            self.error = WalletResponseError(response: response, representation: error)
        }
        
        if let meta = parseDict(representation, param: "response"){
            self.response = WalletResponseMeta(response: response, representation: meta)
        }
    }
    
    
    struct WalletResponseMeta: ResponseObjectSerializable {
        var statusCode: Int
        var body: Body
        
        init?(response: HTTPURLResponse, representation: Any) {
            guard let representation = representation as? [String : Any],
                let statusCode = parseInt(representation, param: "statusCode"),
                let bodyResponse = parseDict(representation, param: "body"),
                let body = Body(response: response, representation: bodyResponse)
                else {return nil}
            
            self.statusCode = statusCode
            self.body = body
        }
        
        struct Body: ResponseObjectSerializable {
            var message: String
            var success: Bool
            
            init?(response: HTTPURLResponse, representation: Any) {
                guard let representation = representation as? [String : Any],
                    let success = parseBool(representation, param: "success"),
                    let message = parseString(representation, param: "Error")
                    else { return nil}
                
                self.success = success
                self.message = message
            }
        }
    }
    
    struct WalletResponseError: ResponseObjectSerializable {
        var success: Bool
        var message: String
        
        init?(response: HTTPURLResponse, representation: Any) {
            guard let representation = representation as? [String : Any],
                let success = parseBool(representation, param: "success"),
                let message = parseString(representation, param: "Error")
                else {return nil}
            
            self.success = success
            self.message = message
        }
        
    }
}
