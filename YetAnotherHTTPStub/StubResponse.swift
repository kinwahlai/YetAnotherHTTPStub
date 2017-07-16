//
//  StubResponse.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/8/17.
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

// MARK: - Content
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

// MARK: - StubResponse
public enum Response {
    case success(response: HTTPURLResponse, content: StubContent)
    case failure(StubError)
}

public typealias Builder = (URLRequest) -> (Response)

public class StubResponse: NSObject {
    private(set) var builder: Builder?
    private(set) var queue: DispatchQueue
    fileprivate var postReplyClosure: (() -> Void) = { }
    private(set) var delay: TimeInterval = 0
    
    var isPartial: Bool {
        return builder == nil
    }
    
    init(queue: DispatchQueue? = nil) {
        if let queue = queue {
            self.queue = queue
        } else {
            self.queue = DispatchQueue(label: "kinwahlai.stubresponse.queue")
        }
    }
    
    @discardableResult
    func assign(builder: @escaping Builder) -> StubResponse {
        self.builder = builder
        return self
    }
    
    @discardableResult
    func setPostReply(_ postReply: @escaping (() -> Void) = {}) -> StubResponse {
        self.postReplyClosure = postReply
        return self
    }

    @discardableResult
    func setResponseDelay(_ delay: TimeInterval) -> StubResponse {
        self.delay = delay
        return self
    }
    
    public func reply(via urlProtocol: URLProtocol) {
        guard let builder = builder else { return }
        queue.asyncAfter(deadline: DispatchTime.now() + delay) {
            let request = urlProtocol.request
            let response = builder(request)
            let client = urlProtocol.client
            switch response {
            case .success(let urlResponse, let content):
                client?.urlProtocol(urlProtocol, didReceive: urlResponse, cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
                if case .data(let data) = content {
                    client?.urlProtocol(urlProtocol, didLoad: data)
                }
                client?.urlProtocolDidFinishLoading(urlProtocol)
            case .failure(let error):
                client?.urlProtocol(urlProtocol, didFailWithError: error)
            }
            self.postReplyClosure()
        }
    }
}
