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
    func registerProtocol() -> Bool {
        self.isProtocolRegistered = URLProtocol.registerClass(YetAnotherURLProtocol.self)
        return isProtocolRegistered
    }
    
    func unregisterProtocol() {
        return URLProtocol.unregisterClass(YetAnotherURLProtocol.self)
    }
    
    @discardableResult
    func whenRequest(matcher: @escaping Matcher) -> StubRequest {
        let stubRequest = StubRequest(matcher)
        stubRequests.append(stubRequest)
        return stubRequest
    }
}
