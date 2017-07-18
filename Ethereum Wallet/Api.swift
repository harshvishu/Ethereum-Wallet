//
//  Api.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/16/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import Foundation
import Alamofire

enum Api:  URLRequestConvertible{
    
    // base url
    static let baseURL = "http://139.59.27.120:8080"
    
    case register(email: String, password: String, name: String, phone: String)
    
    case login(email: String, password: String)
    
    case wallet()
    
    case createWallet()
    
    case history()
    
    case sendFunds(to: String, amount: String)
    
    var method: HTTPMethod{
        switch self {
        case .register, .login, .createWallet, .sendFunds:
            return .post
        case .wallet, .history:
            return .get
        }
    }
    
    var path: String{
        switch self {
        case .register:
            return "/register/"
            
        case .login:
            return "/login/"
            
        case .wallet:
            return "/wallet/ethereum/"
            
        case .createWallet:
            return "/wallet/ethereum/create/"
            
        case .history:
            return "/wallet/ethereum/history/"
            
        case .sendFunds:
            return "/wallet/ethereum/send/"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        // BASE URL
        let url = try Api.baseURL.asURL()
        
        // Make Request
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch  self {
        // REGITER USER
        case let .register(email, passwd, name, phone):
            
            let params: Parameters = [
                "email" : email,
                "password" : passwd,
                "name" : name,
                "phone" : phone
            ]
            
            urlRequest = try URLEncoding.methodDependent.encode(urlRequest, with: params)
            
        // LOGIN USER
        case let .login(email, passwd):
            
            let params: Parameters = [
                "password" : passwd,
                "email" : email
            ]
            
            urlRequest = try URLEncoding.methodDependent.encode(urlRequest, with: params)
            
        case let .sendFunds(to, amount):
            
            let params: Parameters = [
                "to" : to,
                "amount" : amount
            ]
            
            urlRequest = try URLEncoding.methodDependent.encode(urlRequest, with: params)

            
        // nothing
        default:
            break
        }
        
        
        
        return urlRequest
    }
}
