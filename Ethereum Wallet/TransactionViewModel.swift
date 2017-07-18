//
//  TransactionViewModel.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/17/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import Foundation
import UIKit


protocol TransactionViewModelDelegate {
    var date: Date? {get}
    var amount: String? {get}
    
    var image: UIImage? {get}
}

struct TransactionViewModel: TransactionViewModelDelegate {
    
    lazy var numberFormatter:NumberFormatter = {
        // set balance for locale format
        // Rupee symbol for india
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        return numberFormatter
    }()
    
    var date: Date?
    var amount: String?
    
    var image: UIImage?
    
    init(transaction: RecentTransactionsResponse.Transaction, account: Account) {
        date = Date(timeIntervalSince1970: transaction.timeStamp)
        
        if let gas =  Double(transaction.gas){
            amount =  numberFormatter.string(from: NSNumber(value:gas))
        }
        
        if transaction.from == account.xpub{
            image = #imageLiteral(resourceName: "send").tint(color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        }else{
            image = #imageLiteral(resourceName: "receive").tint(color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        }
        
    }
}
