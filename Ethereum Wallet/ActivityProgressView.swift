//
//  ActivityProgressView.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/18/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import UIKit
import Reusable

final class ActivityProgressView: UIView, NibLoadable {
    
    
    @IBOutlet weak var labelMessage: UILabel!
    
    
    func set(message: String?){
        if let message = message{
            labelMessage.text = message
        }
    }
}
