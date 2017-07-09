//
//  StubResponseTests.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/8/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation
import XCTest
@testable import YetAnotherHTTPStub

class StubResponseTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOneBuilderForEachResponse() {
        let errorBuilder: Builder = { urlrequest -> Response in
            return .error(status: 404)
        }
        let stubResponse = StubResponse(errorBuilder)
        XCTAssertNotNil(stubResponse)
        XCTAssertNotNil(stubResponse.builder)
    }
    
    func testErrorResponse() {
        let request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        let errorBuilder: Builder = { urlrequest -> Response in
            return .error(status: 404)
        }
        let (urlResponse, content) = StubResponse(errorBuilder).response(for: request)
        XCTAssertNotNil(urlResponse)
        XCTAssertEqual(urlResponse.statusCode, 404)
        XCTAssertTrue(content == StubContent.noContent)
    }
    
    func testPostResponse() {
        var request = URLRequest(url: URL(string: "https://httpbin.org/post")!)
        request.httpMethod = "POST"
        let errorBuilder: Builder = { urlrequest -> Response in
            return .success(status: 200, headers: [:], content: .noContent)
        }
        let (urlResponse, content) = StubResponse(errorBuilder).response(for: request)
        XCTAssertNotNil(urlResponse)
        XCTAssertEqual(urlResponse.statusCode, 200)
        XCTAssertTrue(content == StubContent.noContent)
    }
    
    func testGetResponse() {
        var request = URLRequest(url: URL(string: "https://httpbin.org/post")!)
        request.httpMethod = "POST"
        let errorBuilder: Builder = { urlrequest -> Response in
            return .success(status: 200, headers: ["Content-Type": "application/json; charset=utf-8"], content: .jsonString("hello"))
        }
        let (urlResponse, content) = StubResponse(errorBuilder).response(for: request)
        XCTAssertNotNil(urlResponse)
        XCTAssertEqual(urlResponse.statusCode, 200)
        XCTAssertEqual(urlResponse.allHeaderFields as! [String: String], ["Content-Type": "application/json; charset=utf-8"])
        XCTAssertTrue(content == StubContent.jsonString("hello"))
    }
}
