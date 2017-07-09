//
//  StubResponse.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/8/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

public enum StubContent {
//    case json(Any)
    case jsonString(String)
    case data(Data)
    case noContent
    
    func toData() -> Data? {
        switch self {
//        case .json(let body):
//            do {
//                let data = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
//                return data
//            } catch {
//                return nil
//            }
        case .jsonString(let string):
            return string.data(using: String.Encoding.utf8)
        case .data(let data):
            return data
        case .noContent:
            return nil
        }
    }
}

public func ==(lhs:StubContent, rhs:StubContent) -> Bool {
    switch(lhs, rhs) {
//    case let (.json(lhsObj), .json(rhsObj)):
//        return (lhsObj == rhsObj)
    case let (.jsonString(lhsString), .jsonString(rhsString)):
        return (lhsString == rhsString)
    case let (.data(lhsData), .data(rhsData)):
        return (lhsData == rhsData) && lhsData.count == rhsData.count
    case (.noContent, .noContent):
        return true
    default:
        return false
    }
}

public enum Response {
    case success(status: Int, headers: Dictionary<String, String>, content: StubContent)
    case error(status: Int)
}

typealias Builder = (URLRequest) -> (Response)

class StubResponse {
    let builder: Builder
    init(_ builder: @escaping Builder) {
        self.builder = builder
    }
    
    func response(for urlrequest: URLRequest) -> (HTTPURLResponse, StubContent) {
        let response = builder(urlrequest)
        switch response {
        case .success(let status, let headers, let content):
            return (HTTPURLResponse(url: urlrequest.url!, statusCode: status, httpVersion: "HTTP/1.1", headerFields: headers)!, content)
        case .error(let status):
            return (HTTPURLResponse(url: urlrequest.url!, statusCode: status, httpVersion: "HTTP/1.1", headerFields: [:])!, .noContent)
        }
    }
}
