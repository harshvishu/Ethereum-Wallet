//
//  RecentTransactionsResponse.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/17/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import Foundation


struct RecentTransactionsResponse: ResponseObjectSerializable {
    var status: Int?
    var message: String?
    var transactions: [Transaction]
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String : Any]
            else {return nil}
        
        status = parseInt(representation, param: "status")
        message = parseString(representation, param: "message")
        
        if let result = representation["result"] as? [[String: Any]]{
            transactions = Transaction.collection(from: response, withRepresentation: result)
        }else{
            transactions = []
        }
        
    }
    
    struct Transaction: ResponseObjectSerializable, ResponseCollectionSerializable {
        var blockNumber: String
        var timeStamp: Double
        var gas: String
        var gasPrice: String
        var value: String
        var cumulativeGasUsed: String
        var gasUsed: String
        
        var from: String
        var to: String
        
        init?(response: HTTPURLResponse, representation: Any) {
            guard let representation = representation as? [String : Any],
            let blockNumber = parseString(representation, param: "blockNumber"),
            let timeStamp = parseDouble(representation, param: "timeStamp"),
            let gas = parseString(representation, param: "gas"),
            let gasPrice = parseString(representation, param: "gasPrice"),
            let value = parseString(representation, param: "value"),
            let cumulativeGasUsed = parseString(representation, param: "cumulativeGasUsed"),
            let gasUsed = parseString(representation, param: "gasUsed"),
            let to = parseString(representation, param: "to"),
            let from = parseString(representation, param: "from")
                else {return nil}
            
            self.blockNumber = blockNumber
            self.timeStamp = timeStamp
            self.gas = gas
            self.gasPrice = gasPrice
            self.value = value
            self.cumulativeGasUsed = cumulativeGasUsed
            self.gasUsed = gasUsed
            
            self.to = to
            self.from = from

        }
    }
}
