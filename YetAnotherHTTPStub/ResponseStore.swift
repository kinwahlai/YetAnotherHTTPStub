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
            if response.deductRepeatCount() <= 0 {
                responses.removeFirst()
            }
            return response
        }else {
            return createFailureResponse(forType: .partialResponse(request))
        }
    }

    func createFailureResponse(forType type: ResponseError) -> StubResponse {
        let param = StubResponse.Parameter().setBuilder(builder: failure(StubError(type.errorMessage())))
        let response = StubResponse().setup(with: param)
        return response
    }

    func addResponse(queue: DispatchQueue) {
        insert(StubResponse(queue: queue), to: .append)
    }
    
    func addResponse(with parameter: StubResponse.Parameter) {
        guard let lastResponse = responses.last else {
            insert(StubResponse().setup(with: parameter), to: .append)
            return
        }
        if lastResponse.isPartial {
            let index = responses.count - 1
            insert(lastResponse.setup(with: parameter), to: .replace(index))
        } else {
            insert(StubResponse(queue: lastResponse.queue).setup(with: parameter), to: .append)
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
