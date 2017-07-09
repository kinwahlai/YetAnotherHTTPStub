//
//  YetAnotherStubRequest.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/8/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

typealias Matcher = (URLRequest) -> (Bool)

class StubRequest {
    let matcher: Matcher
    let url: String
    let method: String
    var responses: [StubResponse]
    init(_ url: String, _ method: String, _ matcher: @escaping Matcher) {
        self.url = url
        self.method = method
        self.matcher = matcher
        self.responses = []
    }
    
    @discardableResult
    func thenResponse(responseBuilder: @escaping Builder) -> Self {
        let stubResponse = StubResponse(responseBuilder)
        self.responses.append(stubResponse)
        return self
    }
    
    func popResponse(for request: URLRequest) -> StubResponse? {
        if matcher(request) {
            return responses.removeFirst()
        } else {
            return nil
        }
    }
}

// func ==(lhs:StubRequest, rhs:StubRequest) -> Bool {
