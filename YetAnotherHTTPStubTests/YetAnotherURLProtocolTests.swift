//
//  YetAnotherHTTPStubTests.swift
//  YetAnotherHTTPStubTests
//
//  Created by Darren Lai on 7/7/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation
import XCTest
@testable import YetAnotherHTTPStub


class YetAnotherURLProtocolTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRegisterProtocolWhenStubHTTPIsCalled() {
        var isProtocolRegistered = false
        YetAnotherURLProtocol.stubHTTP { session in
            isProtocolRegistered = session.isProtocolRegistered
        }
        XCTAssertTrue(isProtocolRegistered)
    }
    
//    func testResetStubSessionWhenReceiveTearDownNotification() {
//        var isProtocolRegistered = false
//        YetAnotherURLProtocol.stubHTTP { session in
//            isProtocolRegistered = session.isProtocolRegistered
//        }
//        XCTAssertTrue(isProtocolRegistered)
//        XCTestObservationCenter
//    }
    
    func testProtocolCannotInitIfProtocolAndRequestRegistered() {
        let request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        YetAnotherURLProtocol.stubHTTP { session in }
        XCTAssertFalse(YetAnotherURLProtocol.canInit(with: request))
    }
    
//    func testProtocolCannotInitIfProtocolAndRequestRegistered() {
//        let session = StubSession()
//        session.whenRequest(matcher: <#T##Matcher##Matcher##(URLRequest) -> (Bool)#>)
//    }
}
