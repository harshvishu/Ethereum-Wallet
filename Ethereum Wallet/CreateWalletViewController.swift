//
//  CreateWalletViewController.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/17/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import UIKit
import Reusable
import Alamofire

class CreateWalletViewController: UIViewController, StoryboardSceneBased {
    
    static var storyboard: UIStoryboard = Storyboards.wallet
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func createWallet(_ sender: Any) {
        let progressView = ActivityProgressView.loadFromNib()
        progressView.set(message: StringConstants.creatingWallet)
        
        self.view.addMaximized(view: progressView)
        
        Alamofire.request(Api.createWallet())
            .responseObject { [weak self] (response: DataResponse<CreateWalletResponse>) in
                guard let `self` = self
                    else {return}
                
                // remove progress view
                progressView.removeFromSuperview()
                
                if case let .success(json) = response.result{
                    
                    if let account = json.account{
                        
                        // send account info 
                        self.sendAccountInfo(account: account)
                        
                        self.alert(StringConstants.walletCreated.capitalized, message: StringConstants.walletCreatedSuccessMessAge, ok: StringConstants.ok.uppercased(), action: { _ in
                            self.dismiss(animated: true, completion: nil)
                        })
                        
                        // return here
                        return
                    }else if let response = json.response{
                        
                        // fetch the error code
                        let errmsg = response.body.errmsg
                        
                        if errmsg.contains("email_1 dup"){
                            self.alert("Email address already in use", message: StringConstants.login_user_message)
                            
                            // we found the error
                            return
                        }
                        if errmsg.contains("phone_1 dup"){
                            self.alert("Phone number already in use", message: StringConstants.login_user_message)
                            
                            // we found the error
                            return
                        }
                    }
                    
                    self.alert("Unable to process!", message: StringConstants.something_went_wrong.capitalized)
                    
                }else if case let .failure(error) = response.result{
                    guard error.localizedDescription != StringConstants.cancelled else {
                        return
                    }
                    self.alert("", message: error.localizedDescription)
                }
        }
        
    }
    
    // send account info to other controllers
    private func sendAccountInfo(account: Account){
        // sentd account
        let dict: [String: Any] = [StringConstants.dictKeyAccount : account]
        
        NotificationCenter.default.post(name: NotificationNames.walletCreated, object: nil, userInfo: dict)
    }
    
    @IBAction func signOut(_ sender: Any) {
        alert(StringConstants.signOut, message: StringConstants.areYouSure, cancellable: true ,ok: StringConstants.ok) { _ in
            logout()
        }
    }
}
