//
//  StubResponse.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/8/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

public enum StubContent: ExpressibleByNilLiteral, Equatable  {
    public init(nilLiteral: ()) {
        self = .noContent
    }
    
    case data(Data)
    case noContent
}

public func ==(lhs:StubContent, rhs:StubContent) -> Bool {
    switch(lhs, rhs) {
    case let (.data(lhsData), .data(rhsData)):
        return (lhsData == rhsData) && lhsData.count == rhsData.count
    case (.noContent, .noContent):
        return true
    default:
        return false
    }
}

public enum Response {
    case success(response: HTTPURLResponse, content: StubContent)
    case failure(NSError)
}


public typealias Builder = (URLRequest) -> (Response)
