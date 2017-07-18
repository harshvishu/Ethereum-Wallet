//
//  UserData.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/16/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import Foundation

struct UserData {
    
    // using Apple's Keychain file to save token in a secure manner
    static var token: String?{
        //getter
        get {
            do{
                let secureItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: StringConstants.token, accessGroup: KeychainConfiguration.accessGroup)
                
                let savedValue = try secureItem.readPassword()
                return savedValue
                
            }catch{
                debugPrint("Error reading token from keychain - \(error)")
            }
            return nil
        }
        
        // setter
        set{
            do{
                
                let secureItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: StringConstants.token, accessGroup: KeychainConfiguration.accessGroup)
                
                guard let token = newValue
                    else {
                        try secureItem.deleteItem()
                        return
                }
                
                try secureItem.savePassword(token)
            }catch{
                debugPrint("Error updating keychain - \(error)")
            }
        }
    }
}
