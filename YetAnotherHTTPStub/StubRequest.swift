//
//  StubRequest.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/8/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

public typealias Matcher = (URLRequest) -> (Bool)
public typealias ParameterConfiguration = (StubResponse.Parameter) -> Void

public class StubRequest: NSObject {
    let matcher: Matcher
    var responseStore: ResponseStore
    
    init(_ matcher: @escaping Matcher) {
        self.matcher = matcher
        self.responseStore = ResponseStore()
    }
    
    @discardableResult
    public func thenResponse(withDelay delay: TimeInterval = 0, repeat count: Int = 1, responseBuilder: @escaping Builder) -> Self {
        responseStore.addResponse(withDelay: delay, repeat: count, postReplyNotify: {}, responseBuilder: responseBuilder)
        return self
    }

    @discardableResult
    public func thenResponse(configurator: ParameterConfiguration ) -> Self {
        let param: StubResponse.Parameter = StubResponse.Parameter()
        configurator(param)
        responseStore.addResponse(withDelay: param.delay, repeat: param.repeatCount, postReplyNotify: param.postReplyClosure, responseBuilder: param.builder)
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

