//
//  StubRequestTests.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/8/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation
import XCTest
@testable import YetAnotherHTTPStub

class StubRequestTests: XCTestCase {
    var trueMatcher: Matcher!
    var falseMatcher: Matcher!
    override func setUp() {
        super.setUp()
        trueMatcher = { _ in
            return true
        }
        falseMatcher = { _ in
            return false
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOneMatcherForEachRequest() {
        let stubRequest = StubRequest(trueMatcher)
        XCTAssertNotNil(stubRequest)
        XCTAssertNotNil(stubRequest.matcher)
    }
    
    func testRequestHasNoStubResponse() {
        let stubRequest = StubRequest(trueMatcher)
        XCTAssertNotNil(stubRequest.responses)
        XCTAssertEqual(stubRequest.responses.count, 0)
    }

    func testRequestHasMultipleStubResponse() {
        let stubRequest = StubRequest(trueMatcher)
        stubRequest.thenResponse(responseBuilder: http(200, headers: [:], content: .noContent))
            .thenResponse(responseBuilder: http(404, headers: [:], content: .noContent))
        
        XCTAssertEqual(stubRequest.responses.count, 2)
    }
    
    
    func testNoResponsesIfDeveloperDidntSetResponse() {
        let httpbin = URLRequest(url: URL(string: "https://www.httpbin.org/")!)
        let stubRequest = StubRequest(falseMatcher)
        let response = stubRequest.popResponse(for: httpbin)
        XCTAssertNil(response)
    }
    
    func testNoResponsesIfRequestNotMatch() {
        let httpbin = URLRequest(url: URL(string: "https://www.httpbin.org/")!)
        let stubRequest = StubRequest(falseMatcher)
        stubRequest.thenResponse(responseBuilder: http(200, headers: [:], content: .noContent))
        let response = stubRequest.popResponse(for: httpbin)
        XCTAssertNil(response)
    }
    
    
    func testFirstResponsesIfRequestMatching() {
        let httpbin = URLRequest(url: URL(string: "https://www.httpbin.org/")!)
        let stubRequest = StubRequest(trueMatcher)
        stubRequest.thenResponse(responseBuilder: jsonString("hello"))
        
        let stubResponse = stubRequest.popResponse(for: httpbin)
        
        if case .success(let urlResponse, let content) = stubResponse!(httpbin) {
            XCTAssertNotNil(urlResponse)
            XCTAssertEqual(urlResponse.statusCode, 200)
            XCTAssertEqual(urlResponse.mimeType, "application/json")
            XCTAssertEqual(urlResponse.textEncodingName, "utf-8")
            XCTAssertTrue(content == StubContent.data("hello".data(using: String.Encoding.utf8)!))
        } else {
            XCTFail()
        }
    }
}
