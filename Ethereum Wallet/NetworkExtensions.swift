//
//  NetworkExtensions.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/16/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import Foundation
import Alamofire

/// Api manager
struct AccessTokenAdapter: RequestAdapter{
    
    private let lock = NSLock()
    private var isRefreshing = false
    private var requestsToRetry = [RequestRetryCompletion]()
    
    // Empty initializer
    init() {}
    
    // MARK: - RequestAdapter
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        //        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        
        let ignore = ["/login/", "/register/"]
        //
        guard let url = urlRequest.url, !ignore.contains(url.lastPathComponent) , let token = UserData.token else
        {return urlRequest}
        
        
        // set the token in header
        urlRequest.setValue(token, forHTTPHeaderField: StringConstants.apiRequestTokenHeader)
        
        return urlRequest
    }
}

extension Request {
    @discardableResult
    public func debugLog() -> Self {
        debugPrint(self)
        return self
    }
}

enum BackendError : Error{
    case network(error: Error) // Capture any underlying Error from the URLSession API
    case dataSerialization(error: Error)
    case jsonSerialization(error: Error)
    case objectSerialization(reason: String)
}

// MARK: Generic Response Object Serialization

public protocol ResponseObjectSerializable{
    init?(response: HTTPURLResponse , representation: Any)
}

extension DataRequest{
    
    @discardableResult func responseObject<T: ResponseObjectSerializable> (
        queue: DispatchQueue? = nil ,
        completionHandler: @escaping (DataResponse<T>) -> Void ) -> Self{
        
        let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
            
            // Return underlying error in case of failure
            guard error == nil else {return .failure(BackendError.network(error: error!))}
            
            // Serialization
            let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = jsonResponseSerializer.serializeResponse(request, response, data, nil)
            
            guard case let .success(jsonObject) = result else{
                return .failure(BackendError.jsonSerialization(error: result.error!))
            }
            
            guard let response = response, let responseObject = T(response: response, representation : jsonObject) else{
                return .failure(BackendError.objectSerialization(reason: "JSON could not be serialized \(jsonObject)"))
            }
            
            return .success(responseObject)
        }
        
        return response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    
    @discardableResult func responseCollection<T: ResponseCollectionSerializable>(
        queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<[T]>) -> Void
        ) -> Self{
        let responseSerializer = DataResponseSerializer<[T]>{ request, response, data, error in
            guard error == nil else{
                return .failure(BackendError.network(error: error!))
            }
            
            let jsonSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = jsonSerializer.serializeResponse(request, response, data, nil)
            
            guard case let .success(jsonObject) = result else{
                return .failure(BackendError.objectSerialization(reason: result.error as? String ?? ""))
            }
            guard let response = response else{
                let result = "Response collection could not be serialized due to nil response."
                return .failure(BackendError.objectSerialization(reason: result))
            }
            return .success(T.collection(from: response, withRepresentation: jsonObject))
        }
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}


protocol ResponseCollectionSerializable {
    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Self]
}

extension ResponseCollectionSerializable where Self: ResponseObjectSerializable{
    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Self] {
        var collection: [Self] = []
        
        if let representation = representation as? [[String: Any]] {
            for itemRepresentation in representation {
                if let item = Self(response: response, representation: itemRepresentation) {
                    collection.append(item)
                }
            }
        }
        
        return collection
    }
}


extension ResponseObjectSerializable{
    
    init?(response: HTTPURLResponse, json str: String) {
        guard let data = str.data(using: .utf8),
            let serialized = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let json = serialized
            else {return nil}
        
        self.init(response: response, representation: json)
    }
}

func parseString(_ representation: [String:Any], param: String) -> String?{
    return representation[param] as? String
}

func parseInt(_ representation: [String:Any], param: String) -> Int?{
    return representation[param] as? Int ?? Int(representation[param] as? String ?? "")
}

func parseDouble(_ representation: [String:Any], param: String) -> Double?{
    return representation[param] as? Double ?? Double(representation[param] as? String ?? "")
}

func parseBool(_ representation: [String:Any], param: String) -> Bool?{
    return representation[param] as? Bool
}

func parseArray(_ representation: [String:Any], param: String) -> [Any]?{
    return representation[param] as? [Any]
}

func parseDict(_ representation: [String: Any], param: String) -> [String:Any]?{
    return representation[param] as?  [String: Any]
}
