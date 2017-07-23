//
//  ResponseStore.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/23/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

public class ResponseStore {
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
    
    fileprivate let nonPartialResponseChecker: (StubResponse) -> Bool = { response -> Bool in return !response.isPartial }
    
    private(set) var responses: [StubResponse]
    
    public var isEmpty: Bool {
        return responses.isEmpty
    }

    public var responseCount: Int {
        return responses.count
    }
    
    init(_ responses: [StubResponse] = []) {
        self.responses = responses
    }
    
    func popResponse(for request: URLRequest) -> StubResponse {
        guard !responses.isEmpty else { return createFailureResponse(forType: .exhaustedResponse(request)) }
        if let _ = responses.first(where: nonPartialResponseChecker) {
            return responses.removeFirst()
        }else {
            return createFailureResponse(forType: .partialResponse(request))
        }
    }

    func createFailureResponse(forType type: ResponseError) -> StubResponse {
        let response = StubResponse().assign(builder: failure(StubError(type.errorMessage())))
        return response
    }

    func addResponse(queue: DispatchQueue) {
        responses.append(StubResponse(queue: queue))
    }
    
    func addResponse(withDelay delay: TimeInterval = 0, responseBuilder: @escaping Builder) {
        guard let lastResponse = responses.last else {
            responses.append(StubResponse()
                .setResponseDelay(delay)
                .assign(builder: responseBuilder))
            return
        }
        if lastResponse.isPartial {
            let index = responses.count - 1
            responses[index] = lastResponse
                .setResponseDelay(delay)
                .assign(builder: responseBuilder)
        } else {
            responses.append(StubResponse(queue: lastResponse.queue)
                .setResponseDelay(delay)
                .assign(builder: responseBuilder))
        }
    }

}
