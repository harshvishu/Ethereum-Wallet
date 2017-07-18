//
//  ReceiveEtherViewController.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/17/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import UIKit
import Reusable

class ReceiveEtherViewController: UIViewController, StoryboardSceneBased {
    static var storyboard: UIStoryboard = Storyboards.wallet
    
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var labelMessage: UILabel!
    
    var account: Account?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = StringConstants.receiveFunds

        // Do any additional setup after loading the view.
        
        if let account = account{
            qrImageView.setQRCodefrom(string: account.xpub)
        }else{
            labelMessage.text = StringConstants.unableToGenerateQRCode
        }
    }
}
