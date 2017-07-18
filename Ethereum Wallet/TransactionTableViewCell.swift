//
//  TransactionTableViewCell.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/17/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import UIKit
import Reusable

class TransactionTableViewCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelAmount: UILabel!

    @IBOutlet weak var imageViewType: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(delegate: TransactionViewModelDelegate){
        
        // set the date
        labelDate.text = delegate.date?.readable()
        
        // set amount
        labelAmount.text = delegate.amount
        
        // set image
        imageViewType.image = delegate.image
    }
}
