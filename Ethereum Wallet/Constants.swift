//
//  Constants.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/16/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import Foundation
import UIKit


struct Storyboards {
    static let main = UIStoryboard(name: "Main", bundle: nil)
    static let loginRegister = UIStoryboard(name: "LoginRegister", bundle: nil)
    static let wallet = UIStoryboard(name: "Wallet", bundle: nil)
}

struct StringConstants {
    static let token = "token"
    static let register = "register"
    static let login = "login"
    
    static let register_user_message = "New user? Register!"
    static let login_user_message = "Already have an account? Login!"
    
    static let creatingAccount = "Creating Account..."
    static let signingIn = "Signing In..."
    
    static let invalid_email = "Invalid Email"
    static let prompt_invalid_email = "Enter a valid email"
    
    static let no_name = "No Name"
    static let prompt_no_name = "Enter a valid name"
    static let alert = "Alert"
    
    static let invalid_phone = "Invalid Phone"
    static let prompt_invalid_phone = "Enter a valid phone number"
    
    static let invalid_password = "Invalid Password"
    static let prompt_invalid_password = "Enter a valid password"
    
    
    static let something_went_wrong = "something went wrong"
    static let cancelled = "cancelled"
    static let Cancel = "Cancel"
    
    static let appName = "Ethereum Wallet"
    
    static let apiRequestTokenHeader = "x-access-token"
    static let walletNotFoundError = "Wallet not found"
    static let invalidTokenError = "JsonWebTokenError"
    static let recentTransactions = "recent transactions"
    
    static let walletCreated = "wallet created"
    static let walletCreatedSuccessMessAge = "Let's go checkout all cool stuff you can do"
    static let ok = "ok"
    
    static let xpub = "xpub"
    static let user = "user"
    static let id = "id"
    
    static let unableToGenerateQRCode = "Unable to generate QR Code"
    static let receiveFunds = "Receive Funds"
    static let fundsTransfer = "Funds Transfer"
    static let accountNotAvailable = "Account details not available"
    static let scanNoUserAlert = "Scan a QR Code to send funds"
    static let invalidAmount = "Enter a valid amount"
    static let transferingFunds = "Transferring funds. Don't press back!"
    static let transferSuccessful = "Funds were successfully transfered!"
    
    static let dictKeyAccount = "dictKeyAccount"
    static let creatingWallet = "Creating Wallet"
    static let signOut = "Sign Out"
    static let areYouSure = "Are you sure?"
}

struct  NotificationNames {
    static let didLogin = Notification.Name("didLogin")
    static let didLogout = Notification.Name("didLogout")
    static let walletCreated = Notification.Name("walletCreated")
}

// global static function to logout
func logout(){
    NotificationCenter.default.post(name: NotificationNames.didLogout, object: nil)
}
