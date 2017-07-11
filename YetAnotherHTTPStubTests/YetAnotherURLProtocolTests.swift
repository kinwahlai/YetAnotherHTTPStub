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
        
        // NOTE: Create your stub before get your session configuration
        YetAnotherURLProtocol.stubHTTP { session in
            session.whenRequest { (urlrequest) -> (Bool) in
                return true
                }.thenResponse(responseBuilder: http(404))
        }
        
        let configuration = URLSessionConfiguration.default
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
    
    func testIntegrationTestingWithSequenceResponse() {
        let expectation = self.expectation(description: "StubTests1")
        YetAnotherURLProtocol.stubHTTP { session in
            session.whenRequest {
                return everything($0)
                }.thenResponse(responseBuilder: jsonString("{\"hello\":\"world\"}", status: 200))
                .thenResponse(responseBuilder: jsonString("{\"errors\": \"something\"", status: 404))
        }
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        let datatask2 = session.dataTask(with: URL(string: "https://httpbin.org/GET")!, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                XCTAssertNotNil(response)
                let statusCode = (response as! HTTPURLResponse).statusCode
                XCTAssertEqual(statusCode, 404)
                expectation.fulfill()
            }
        })
        
        let dataTask1 = session.dataTask(with: URL(string: "https://httpbin.org/POST")!, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                XCTAssertNotNil(response)
                let statusCode = (response as! HTTPURLResponse).statusCode
                XCTAssertEqual(statusCode, 200)
                datatask2.resume()
            }
        })
        
        
        dataTask1.resume()
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "\(error)")
        }
        
        
    }
}
