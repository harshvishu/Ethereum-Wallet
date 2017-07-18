//
//  UserLoginResponse.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/16/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import Foundation

struct UserLoginResponse: ResponseObjectSerializable {
    var name: String?
    var statusCode: Int?
    
    
    var token: String?
    var id: String?
    
    var meta: UserLoginMeta?
    var error: UserLoginError?
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String : Any]
            else {return nil}
        
        name = parseString(representation, param: "name")
        statusCode = parseInt(representation, param: "statusCode")
        
        // token & id
        if let token = parseString(representation, param: "token"),
            let id = parseString(representation, param: "_id"){
            self.token = token
            self.id = id
        }
        
        if let meta = parseDict(representation, param: "response"){
            self.meta = UserLoginMeta(response: response, representation: meta)
        }

        if let error = parseDict(representation, param: "error"){
            self.error = UserLoginError(response: response, representation: error)
        }
    }
    
    struct UserLoginMeta: ResponseObjectSerializable {
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
            var status: Int
            
            init?(response: HTTPURLResponse, representation: Any) {
                guard let representation = representation as? [String : Any],
                    let status = parseInt(representation, param: "status"),
                    let message = parseString(representation, param: "message")
                    else { return nil}
                
                self.status = status
                self.message = message
            }
        }
    }
    
    struct UserLoginError: ResponseObjectSerializable {
        var status: Int
        var message: String
        
        init?(response: HTTPURLResponse, representation: Any) {
            guard let representation = representation as? [String : Any],
                let status = parseInt(representation, param: "status"),
                let message = parseString(representation, param: "message")
                else {return nil}
            
            self.status = status
            self.message = message
        }
        
    }

}
