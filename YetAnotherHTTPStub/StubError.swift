//
//  StubError.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/23/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

// MARK: - Error
public struct StubError: Error, Equatable {
    public var message: String
    var localizedDescription: String {
        return message
    }
    
    init(_ message: String) {
        self.message = message
    }
}

public func ==(lhs:StubError, rhs:StubError) -> Bool {
    return lhs.message == rhs.message
}
