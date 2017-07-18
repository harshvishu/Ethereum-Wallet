//
//  CreateWalletResponse.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/17/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import Foundation


struct CreateWalletResponse: ResponseObjectSerializable {
    var name: String?
    var statusCode: Int?
    
    var account: Account?
    
    var response: WalletMeta?
    var error: WalletError?
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String : Any]
            else {return nil}
        
        account = Account(response: response, representation: representation)
        
        name = parseString(representation, param: "name")
        statusCode = parseInt(representation, param: "statusCode")
        
        if let meta = parseDict(representation, param: "response"){
            self.response = WalletMeta(response: response, representation: meta)
        }
        
        if let error = parseDict(representation, param: "error"){
            self.error = WalletError(response: response, representation: error)
        }

    }
    
    struct WalletMeta: ResponseObjectSerializable {
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
            var errmsg: String
            var code: Int
            
            init?(response: HTTPURLResponse, representation: Any) {
                guard let representation = representation as? [String : Any],
                    let code = parseInt(representation, param: "code"),
                    let errmsg = parseString(representation, param: "errmsg")
                    else { return nil}
                
                self.code = code
                self.errmsg = errmsg
            }
        }
    }
    
    struct WalletError: ResponseObjectSerializable {
        var code: Int
        var errmsg: String
        
        init?(response: HTTPURLResponse, representation: Any) {
            guard let representation = representation as? [String : Any],
                let code = parseInt(representation, param: "code"),
                let errmsg = parseString(representation, param: "errmsg")
                else {return nil}
            
            self.code = code
            self.errmsg = errmsg
        }
        
    }
}
