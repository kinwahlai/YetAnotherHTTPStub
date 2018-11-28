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
    
    // to be deprecated in next version
    @available(*, deprecated, message: "use thenResponse(configurator:) instead")
    @discardableResult
    public func thenResponse(withDelay delay: TimeInterval = 0, repeat count: Int = 1, responseBuilder: @escaping Builder) -> Self {
        let param: StubResponse.Parameter = StubResponse.Parameter()
                                            .setResponseDelay(delay)
                                            .setRepeatable(count)
                                            .setPostReply({})
                                            .setBuilder(builder: responseBuilder)
        addResponse(param)
        return self
    }

    @discardableResult
    public func thenResponse(configurator: ParameterConfiguration ) -> Self {
        let param: StubResponse.Parameter = StubResponse.Parameter()
        configurator(param)
        addResponse(param)
        return self
    }
    
    private func addResponse(_ parameter: StubResponse.Parameter) {
        responseStore.addResponse(with: parameter)
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

