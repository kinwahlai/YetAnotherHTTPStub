//
//  YetAnotherStubSession.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/8/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

// concept
// 1 session -> n matcher
// 1 macther -> n response builder, operate in sequence

public class StubSession {
    internal var isProtocolRegistered = false
    internal var uuid: UUID
    internal var stubRequests: [StubRequest]
    
    public var hasRequest: Bool {
        return stubRequests.count > 0
    }
    
    public init(uuid: UUID = UUID()) {
        self.uuid = uuid
        self.stubRequests = []
    }
    
    @discardableResult
    public func addProtocol(to configuration: URLSessionConfiguration?) -> Bool {
        self.isProtocolRegistered = true
        guard let configuration = configuration else {
            return isProtocolRegistered
        }
        var protocolClasses: [AnyClass] = Array(configuration.protocolClasses!)
        protocolClasses.insert(YetAnotherURLProtocol.self, at: 0)
        configuration.protocolClasses = protocolClasses
        return isProtocolRegistered
    }
    
    public func removeProtocol(from configuration: URLSessionConfiguration) {
        self.isProtocolRegistered = false
        let protocolClasses: [AnyClass] = Array(configuration.protocolClasses!)
        configuration.protocolClasses = protocolClasses.filter({ $0 != YetAnotherURLProtocol.self })
    }
    
    @discardableResult
    public func whenRequest(url: String, method: String, matcher: @escaping Matcher) -> StubRequest {
        let stubRequest = StubRequest(url, method, matcher)
        stubRequests.append(stubRequest)
        return stubRequest
    }
    
    public func find(by urlRequest: URLRequest) -> StubRequest? {
        guard let url = urlRequest.url?.absoluteString, let method = urlRequest.httpMethod else { return nil }
        return stubRequests.first { (stub) -> Bool in
            return stub.compare(url, method)
        }
    }
}

public func ==(lhs:StubSession, rhs:StubSession) -> Bool {
    return (lhs.uuid == rhs.uuid)
}
