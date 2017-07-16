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
    enum ResponseError {
        case exhaustedResponse(URLRequest)
        case partialResponse(URLRequest)
        
        func errorMessage() -> String {
            switch self {
            case .exhaustedResponse(let request):
                return "There isn't any(more) response for this request \(request)"
            case .partialResponse(let request):
                return "Cannot process partial response for this request \(request)"
            }
        }
    }
    internal let matcher: Matcher
    internal var responses: [StubResponse]
    fileprivate let nonPartialResponseChecker: (StubResponse) -> Bool = { response -> Bool in return !response.isPartial }
    
    internal init(_ matcher: @escaping Matcher) {
        self.matcher = matcher
        self.responses = []
    }
    
    @discardableResult
    public func thenResponse(responseBuilder: @escaping Builder) -> Self {
        guard let lastResponse = responses.last else {
            responses.append(StubResponse().assign(builder: responseBuilder))
            return self
        }
        if lastResponse.isPartial {
            let index = responses.count - 1
            responses[index] = lastResponse.assign(builder: responseBuilder)
        } else {
            responses.append(StubResponse(queue: lastResponse.queue).assign(builder: responseBuilder))
        }
        
        return self
    }
    
    @discardableResult
    public func responseOn(queue: DispatchQueue) -> Self {
        responses.append(StubResponse(queue: queue))
        return self
    }
    
    // outgoing
    internal func popResponse(for request: URLRequest) -> StubResponse? {
        guard matcher(request) == true else { return nil }
        guard !responses.isEmpty else { return createFailureResponse(forType: .exhaustedResponse(request)) }
        if let _ = responses.first(where: nonPartialResponseChecker) {
            return responses.removeFirst()
        }else {
            return createFailureResponse(forType: .partialResponse(request))
        }
    }
    
    internal func createFailureResponse(forType type: ResponseError) -> StubResponse {
        let response = StubResponse().assign(builder: failure(StubError(type.errorMessage())))
        return response
    }
}

