//
//  YetAnotherStubRequest.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/8/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

public typealias Matcher = (URLRequest) -> (Bool)

public class StubRequest: NSObject {
    internal let matcher: Matcher
    internal var responses: [StubResponse]
    
    internal init(_ matcher: @escaping Matcher) {
        self.matcher = matcher
        self.responses = []
    }
    
    @discardableResult
    public func thenResponse(responseBuilder: @escaping Builder) -> Self {
        let stubResponse = StubResponse(responseBuilder)
        self.responses.append(stubResponse)
        return self
    }
    
    internal func popResponse(for request: URLRequest) -> StubResponse? {
        if matcher(request) && !responses.isEmpty {
            return responses.removeFirst()
        } else {
            return nil
        }
    }
}

// func ==(lhs:StubRequest, rhs:StubRequest) -> Bool {
