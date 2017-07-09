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

class StubSession {
    var isProtocolRegistered = false
    var uuid: UUID
    var stubRequests: [StubRequest]
    
    init(uuid: UUID = UUID()) {
        self.uuid = uuid
        self.stubRequests = []
    }
    
    @discardableResult
    func addProtocol(to configuration: URLSessionConfiguration?) -> Bool {
        self.isProtocolRegistered = true
        guard let configuration = configuration else {
            return isProtocolRegistered
        }
        var protocolClasses: [AnyClass] = Array(configuration.protocolClasses!)
        protocolClasses.insert(YetAnotherURLProtocol.self, at: 0)
        configuration.protocolClasses = protocolClasses
        return isProtocolRegistered
    }
    
    func removeProtocol(from configuration: URLSessionConfiguration) {
        self.isProtocolRegistered = false
        let protocolClasses: [AnyClass] = Array(configuration.protocolClasses!)
        configuration.protocolClasses = protocolClasses.filter({ $0 != YetAnotherURLProtocol.self })
    }
    
    @discardableResult
    func whenRequest(url: String, method: String, matcher: @escaping Matcher) -> StubRequest {
        let stubRequest = StubRequest(url, method, matcher)
        stubRequests.append(stubRequest)
        return stubRequest
    }
    
    func find(by urlRequest: URLRequest) -> StubRequest? {
        guard let url = urlRequest.url?.absoluteString, let method = urlRequest.httpMethod else { return nil }
        return stubRequests.first { (request) -> Bool in
            return (request.url == url && request.method == method)
        }
    }
}
