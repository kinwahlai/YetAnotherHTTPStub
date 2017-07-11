//
//  StubSession.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/8/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

// concept
// 1 session -> n matcher
// 1 macther -> n response builder, operate in sequence

public class StubSession: NSObject {
    internal var isProtocolRegistered = false
    internal var uuid: UUID
    internal var stubRequests: [StubRequest]
    public var testCaseDidFinishBlock: (()->()) = {}
    
    public var hasRequest: Bool {
        return stubRequests.count > 0
    }
    
    public var protocolClass: AnyClass {
        return YetAnotherURLProtocol.self
    }
    
    internal init(uuid: UUID = UUID()) {
        self.uuid = uuid
        self.stubRequests = []
    }
    
    func injectProtocolToDefaultConfigs() {
        guard isProtocolRegistered == false else { return }
        let configuration = URLSessionConfiguration.default
        if (configuration.protocolClasses!).map({ "\($0)" }).contains("YetAnotherURLProtocol") {
            isProtocolRegistered = true
            return
        }
        
        URLSessionConfiguration.swizzleYetAnotherHTTPStubSessionConfiguration()
        isProtocolRegistered = true
    }
    
    @discardableResult
    public func whenRequest(matcher: @escaping Matcher) -> StubRequest {
        let stubRequest = StubRequest(matcher)
        stubRequests.append(stubRequest)
        return stubRequest
    }
    
    internal func find(by urlRequest: URLRequest) -> StubRequest? {
        return stubRequests.first { (stub) -> Bool in
            return stub.matcher(urlRequest)
        }
    }
}

public func ==(lhs:StubSession, rhs:StubSession) -> Bool {
    return (lhs.uuid == rhs.uuid)
}
