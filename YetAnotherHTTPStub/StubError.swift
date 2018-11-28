//
//  StubError.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/23/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

// MARK: - Error
public enum StubError: Error, Equatable {
    case other(String)
    case exhaustedResponse(URLRequest)
    case partialResponse(URLRequest)
    
    public var localizedDescription: String {
        switch self {
        case .other(let message):
            return message
        case .exhaustedResponse(let request):
            return "There isn't any(more) response for this request \(request)"
        case .partialResponse(let request):
            return "Cannot process partial response for this request \(request)"
        }
    }
    
    public var toNSError: NSError {
        switch self {
        case .other:
            return NSError(domain: "YetAnotherHTTPStub.StubError", code: -969, userInfo: ["message": self.localizedDescription])
        case .exhaustedResponse:
            return NSError(domain: "YetAnotherHTTPStub.StubError", code: -979, userInfo: ["message": self.localizedDescription])
        case .partialResponse:
            return NSError(domain: "YetAnotherHTTPStub.StubError", code: -959, userInfo: ["message": self.localizedDescription])
        }
    }
}

public func ==(lhs:StubError, rhs:StubError) -> Bool {
    switch(lhs, rhs) {
    case let (.other(lhsMessage), .other(rhsMessage)):
        return lhsMessage == rhsMessage
    case let (.exhaustedResponse(lhsURL), .exhaustedResponse(rhsURL)):
        return lhsURL == rhsURL
    case let (.partialResponse(lhsURL), .partialResponse(rhsURL)):
        return lhsURL == rhsURL
    default:
        return false
    }
}
