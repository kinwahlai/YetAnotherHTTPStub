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
    
    public var responses: [StubResponse]
    
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

}
