//
//  StubRequest.swift
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
        self.responses.append(StubResponse(responseBuilder))
        return self
    }
    
    internal func popResponse(for request: URLRequest) -> StubResponse? {
        guard matcher(request) == true else { return nil }
        if responses.isEmpty {
            return createFailureResponse(forRequest: request)
        } else {
            return responses.removeFirst()
        }
    }
    
    internal func createFailureResponse(forRequest request: URLRequest) -> StubResponse {
        return StubResponse(failure(StubError("There isn't any(more) response for this request \(request)")))
    }
}
