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
        let errorBuilder: Builder = http(404)
        let stubResponse = StubResponse(errorBuilder)
        XCTAssertNotNil(stubResponse)
        XCTAssertNotNil(stubResponse.builder)
    }
    
    func testErrorResponse() {
        let request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        let errorBuilder: Builder = http(404)
        if case .success(let urlResponse, let content) = StubResponse(errorBuilder).builder(request) {
            XCTAssertNotNil(urlResponse)
            XCTAssertEqual(urlResponse.statusCode, 404)
            XCTAssertTrue(content == StubContent.noContent)
        } else {
            XCTFail()
        }
    }
    
    func testPostResponse() {
        var request = URLRequest(url: URL(string: "https://httpbin.org/post")!)
        request.httpMethod = "POST"
        let responseBuilder: Builder = http(200)
        if case .success(let urlResponse, let content) = StubResponse(responseBuilder).builder(request) {
            XCTAssertNotNil(urlResponse)
            XCTAssertEqual(urlResponse.statusCode, 200)
            XCTAssertTrue(content == StubContent.noContent)
        } else {
            XCTFail()
        }
    }
    
    func testGetResponse() {
        var request = URLRequest(url: URL(string: "https://httpbin.org/post")!)
        request.httpMethod = "POST"
        let responseBuilder: Builder = http(200, headers: ["Content-Type": "application/json; charset=utf-8"], content: .data("hello".data(using: String.Encoding.utf8)!))
        if case .success(let urlResponse, let content) = StubResponse(responseBuilder).builder(request) {
            XCTAssertNotNil(urlResponse)
            XCTAssertEqual(urlResponse.statusCode, 200)
            XCTAssertTrue(content == StubContent.data("hello".data(using: String.Encoding.utf8)!))
        } else {
            XCTFail()
        }

    }
}
