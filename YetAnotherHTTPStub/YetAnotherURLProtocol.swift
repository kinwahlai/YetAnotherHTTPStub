//
//  YetAnotherURLProtocol.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/7/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

class YetAnotherURLProtocol: URLProtocol {
    class func stubHTTP(_ sessionBlock: (StubSession)->()) {
        let session = StubSessionManager.sharedSession()
        session.registerProtocol()
        // Here we may want to register to XCTestObservation so we can reset the session
        sessionBlock(session)
    }
    
    override class func canInit(with request:URLRequest) -> Bool {
        return false
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        print("startLoading")
    }
    
    override func stopLoading() {
        print("stopLoading")
    }
}
