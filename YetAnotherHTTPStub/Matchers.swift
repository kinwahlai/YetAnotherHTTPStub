//
//  Matchers.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/9/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

public func everything(_ urlrequest: URLRequest) -> Bool {
    return true
}

public func nothing(_ urlrequest: URLRequest) -> Bool {
    return false
}

public func uri(_ uri:String) -> (_ urlrequest: URLRequest) -> Bool {
    return { (_ urlrequest: URLRequest) -> Bool in
        guard let urlstring = urlrequest.url?.absoluteString, let _ = urlrequest.url?.path else {
            return false
        }
        guard var encodedUri = uri.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return false
        }
        //restore wildcard backslashes that were encoded
        encodedUri = encodedUri.replacingOccurrences(of: "%5C", with: "\\")

        //escape regex characters
        encodedUri = encodedUri.replacingOccurrences(of: "?", with: "\\?")
        encodedUri = encodedUri.replacingOccurrences(of: "+", with: "\\+")
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", encodedUri)

        if predicate.evaluate(with: urlstring) { return true }
        
        if let path = urlrequest.url?.path {
            var pathWithQuery = path
            if let query = urlrequest.url?.query {
                pathWithQuery = "\(path)?\(query)"
            }
            if predicate.evaluate(with: pathWithQuery)  { return true }
        }
        
        return false
    }
}

public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

public func http(_ method: HTTPMethod, uri: String) -> (_ urlrequest: URLRequest) -> Bool {
    return { (_ urlrequest: URLRequest) -> Bool in
        guard let requestMethod = urlrequest.httpMethod else { return false }
        if (requestMethod == method.rawValue && YetAnotherHTTPStub.uri(uri)(urlrequest)) {
            return true
        }
        return false
    }
}
