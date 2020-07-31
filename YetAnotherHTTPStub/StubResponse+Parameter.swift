//
//  StubResponse+Parameter.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 8/27/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//
import Foundation

extension StubResponse {
    public class Parameter {
        private(set) var delay: TimeInterval = 0
        private(set) var repeatCount: Int = 1
        private(set) var builder: Builder = http()
        private(set) var postReplyClosure: (()->Void) = { }
        
        @discardableResult
        public func setBuilder(builder: @escaping Builder) -> StubResponse.Parameter {
            self.builder = builder
            return self
        }
        
        @discardableResult
        public func setPostReply(_ postReply: @escaping (()->Void)) -> StubResponse.Parameter {
            postReplyClosure = postReply
            return self
        }
        
        @discardableResult
        public func setResponseDelay(_ delay: TimeInterval) -> StubResponse.Parameter {
            self.delay = delay
            return self
        }
        
        @discardableResult
        public func setRepeatable(_ count: Int) -> StubResponse.Parameter {
            repeatCount = count
            return self
        }
    }
}

