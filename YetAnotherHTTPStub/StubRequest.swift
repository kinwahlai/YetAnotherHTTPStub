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
    var responses: [StubResponse]
    init(_ matcher: @escaping Matcher) {
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
