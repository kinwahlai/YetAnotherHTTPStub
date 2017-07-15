//
//  StubResponse.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/8/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

// MARK: - Error
public struct StubError: Error, Equatable {
    var message: String
    var localizedDescription: String {
        return message
    }
    
    init(_ message: String) {
        self.message = message
    }
}

public func ==(lhs:StubError, rhs:StubError) -> Bool {
    return lhs.message == rhs.message
}

// MARK: - Content
public enum StubContent: ExpressibleByNilLiteral, Equatable  {
    public init(nilLiteral: ()) {
        self = .noContent
    }
    
    case data(Data)
    case noContent
}

public func ==(lhs:StubContent, rhs:StubContent) -> Bool {
    switch(lhs, rhs) {
    case let (.data(lhsData), .data(rhsData)):
        return (lhsData == rhsData) && lhsData.count == rhsData.count
    case (.noContent, .noContent):
        return true
    default:
        return false
    }
}

// MARK: - StubResponse
public enum Response {
    case success(response: HTTPURLResponse, content: StubContent)
    case failure(StubError)
}

public typealias Builder = (URLRequest) -> (Response)

public class StubResponse: NSObject {
    fileprivate let builder: Builder
    init(_ builder: @escaping Builder) {
        self.builder = builder
    }
    
    public func reply(via urlProtocol: URLProtocol) {
        let request = urlProtocol.request
        let response = builder(request)
        let client = urlProtocol.client
        switch response {
        case .success(let urlResponse, let content):
            client?.urlProtocol(urlProtocol, didReceive: urlResponse, cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
            if case .data(let data) = content {
                client?.urlProtocol(urlProtocol, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(urlProtocol)
        case .failure(let error):
            client?.urlProtocol(urlProtocol, didFailWithError: error)
        }
    }
}

