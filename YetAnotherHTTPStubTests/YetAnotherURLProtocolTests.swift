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
        StubSessionManager.removeSharedSession()
        super.tearDown()
    }
    
    func testProtocolCannotInitIfProtocolRegisteredButNoRequest() {
        let request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        YetAnotherURLProtocol.stubHTTP { session in }
        XCTAssertFalse(YetAnotherURLProtocol.canInit(with: request))
    }

    func testProtocolCanInitIfMatcherTrueAndHasRequest() {
        let request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        YetAnotherURLProtocol.stubHTTP { session in
            session.whenRequest { (urlrequest) -> (Bool) in
                return true
            }
        }
        XCTAssertTrue(YetAnotherURLProtocol.canInit(with: request))
    }
    
    func testIntegrationTestingFor404() {
        let expectation = self.expectation(description: "StubTests")
        
        let configuration = URLSessionConfiguration.default
        YetAnotherURLProtocol.stubHTTP(configuration) { session in
            session.whenRequest { (urlrequest) -> (Bool) in
                return true
            }.thenResponse { (_) -> (Response) in
                return .error(status: 404)
            }
        }
        
        let session = URLSession(configuration: configuration)
        session.dataTask(with: URL(string: "https://httpbin.org/")!, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                XCTAssertNotNil(response)
                let statusCode = (response as! HTTPURLResponse).statusCode
                XCTAssertEqual(statusCode, 404)
                expectation.fulfill()
            }
        }).resume()
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}
