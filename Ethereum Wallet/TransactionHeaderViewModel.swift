//
//  TransactionHeaderViewModel.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/17/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import Foundation
import UIKit

protocol TransactionHeaderViewModelDelegate {
    func sendFunds()
    func receiveFunds()
}

struct TransactionHeaderViewModel: TransactionHeaderViewModelDelegate {
    
    weak var viewController: UIViewController?
    
    let account: Account
    
    init(viewController: UIViewController, account: Account) {
        self.viewController = viewController
        self.account = account
    }
    
    func sendFunds() {
        let controller = SendEtherViewController.instantiate()
        controller.account = account
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
    func receiveFunds() {
        let controller = ReceiveEtherViewController.instantiate()
        controller.account = account
        
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
}
