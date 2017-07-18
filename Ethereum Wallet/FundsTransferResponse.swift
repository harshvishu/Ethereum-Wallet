//
//  FundsTransferResponse.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/17/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import Foundation


struct FundsTransferResponse: ResponseObjectSerializable {
    var name: String?
    var statusCode: Int?
    
    var error: FundsTransferError?
    var response: FundsTransferMeta?
    
    var transaction: FundsTransaction?
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String : Any]
            else {return nil}
        
        name = parseString(representation, param: "name")
        statusCode = parseInt(representation, param: "statusCode")
        
        
        if let error = parseDict(representation, param: "error"){
            self.error = FundsTransferError(response: response, representation: error)
        }
        
        if let meta = parseDict(representation, param: "response"){
            self.response = FundsTransferMeta(response: response, representation: meta)
        }
        
        self.transaction = FundsTransaction(response: response, representation: representation)
    }
    
    struct FundsTransaction: ResponseObjectSerializable {
        var from: String
        var to: String
        var walletId: String
        var value: Int
        var nonce: Int
        var gasLimit: Int
        var gasPrice: String
        var txHash: String
        
        init?(response: HTTPURLResponse, representation: Any) {
            guard let representation = representation as? [String : Any],
                let to = parseString(representation, param: "to"),
                let from = parseString(representation, param: "from"),
                let walletId = parseString(representation, param: "walletId"),
                let value = parseInt(representation, param: "value"),
                let nonce = parseInt(representation, param: "nonce"),
                let gasLimit = parseInt(representation, param: "gasLimit"),
                let gasPrice = parseString(representation, param: "gasPrice"),
                let txHash = parseString(representation, param: "txHash")
                else {return nil}
            
            self.from = from
            self.to = to
            self.walletId = walletId
            self.value = value
            self.nonce = nonce
            self.gasLimit = gasLimit
            self.gasPrice = gasPrice
            self.txHash = txHash
        }
    }
    
    struct FundsTransferMeta: ResponseObjectSerializable {
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
    
    struct FundsTransferError: ResponseObjectSerializable {
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
