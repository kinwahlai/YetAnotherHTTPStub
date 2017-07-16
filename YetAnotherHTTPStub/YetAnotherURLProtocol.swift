//
//  YetAnotherURLProtocol.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/7/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

public func getThreadName() -> String {
    if Thread.current.isMainThread {
        return "Main Thread"
    } else if let name = Thread.current.name {
        if name == "" {
            return "Anonymous Thread"
        }
        return name
    } else {
        return "Unknown Thread"
    }
}

public class YetAnotherURLProtocol: URLProtocol {
    public class func stubHTTP(_ addSessionToXCTestObservationCenter: Bool = true, _ sessionBlock: (StubSession)->()) {
        let session = StubSessionManager.sharedSession()
        session.injectProtocolToDefaultConfigs()
        if addSessionToXCTestObservationCenter {
            session.addToTestObserver()
        }
        sessionBlock(session)
    }
}

extension YetAnotherURLProtocol {
    public override class func canInit(with request:URLRequest) -> Bool {
        return (StubSessionManager.sharedSession().isProtocolRegistered && StubSessionManager.sharedSession().hasRequest)
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    public override func startLoading() {
        guard let stubRequest = StubSessionManager.sharedSession().find(by: request) else { return }
        guard let stubResponse = stubRequest.popResponse(for: request) else { return }
        stubResponse.reply(via: self)
    }
    
    public override func stopLoading() {
        print("stopLoading")
    }
}
