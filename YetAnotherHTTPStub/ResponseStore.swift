//
//  ResponseStore.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/23/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

public class ResponseStore {
    enum InsertType {
        case append
        case replace(Int)
    }
    
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
        if let response = responses.first(where: nonPartialResponseChecker) {
            if response.setRepeatable(response.repeatCount - 1).repeatCount <= 0 {
                responses.removeFirst()
            }
            return response
        }else {
            return createFailureResponse(forType: .partialResponse(request))
        }
    }

    func createFailureResponse(forType type: ResponseError) -> StubResponse {
        let response = StubResponse().assign(builder: failure(StubError(type.errorMessage())))
        return response
    }

    func addResponse(queue: DispatchQueue) {
        insert(StubResponse(queue: queue), to: .append)
    }
    
    func addResponse(withDelay delay: TimeInterval = 0, repeat count: Int = 1, responseBuilder: @escaping Builder) {
        guard let lastResponse = responses.last else {
            insert(StubResponse()
                .setResponseDelay(delay)
                .setRepeatable(count)
                .assign(builder: responseBuilder), to: .append)
            return
        }
        if lastResponse.isPartial {
            let index = responses.count - 1
            insert(lastResponse
                .setResponseDelay(delay)
                .setRepeatable(count)
                .assign(builder: responseBuilder), to: .replace(index))
        } else {
            insert(StubResponse(queue: lastResponse.queue)
                .setResponseDelay(delay)
                .setRepeatable(count)
                .assign(builder: responseBuilder), to: .append)
        }
    }
    
    fileprivate func insert(_ response: StubResponse, to type:InsertType) {
        switch type {
        case .append:
            responses.append(response)
            break;
        case .replace(let idx):
            responses[idx] = response
            break;
        }
    }
}
