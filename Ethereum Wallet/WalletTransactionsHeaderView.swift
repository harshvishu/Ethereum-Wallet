//
//  WalletTransactionsHeaderView.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/17/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import UIKit
import Reusable

class WalletTransactionsHeaderView: UITableViewCell, NibReusable {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var completetionHandlerSend: (() -> Void)?
    var completetionHandlerReceive: (() -> Void)?

    
    @IBAction func actionSend(_ sender: Any) {
        completetionHandlerSend?()
    }
    
    @IBAction func actionReceive(_ sender: Any) {
        completetionHandlerReceive?()
    }

    func configure(delegate:  TransactionHeaderViewModelDelegate){
        completetionHandlerSend  = delegate.sendFunds
        completetionHandlerReceive = delegate.receiveFunds
    }
}
