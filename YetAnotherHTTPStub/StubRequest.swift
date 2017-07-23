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
    let matcher: Matcher
    var responseStore: ResponseStore
    
    init(_ matcher: @escaping Matcher) {
        self.matcher = matcher
        self.responseStore = ResponseStore()
    }
    
    @discardableResult
    public func thenResponse(withDelay delay: TimeInterval = 0, responseBuilder: @escaping Builder) -> Self {
        responseStore.addResponse(withDelay: delay, responseBuilder: responseBuilder)
        return self
    }
    
    @discardableResult
    public func responseOn(queue: DispatchQueue) -> Self {
        responseStore.addResponse(queue: queue)
        return self
    }
    
    // outgoing
    func popResponse(for request: URLRequest) -> StubResponse? {
        guard matcher(request) == true else { return nil }
        return responseStore.popResponse(for: request)
    }
}

