//
//  BuildersTests.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/10/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation
import XCTest
@testable import YetAnotherHTTPStub

class BuildersTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testBuildDefaultHTTPResponse() {
        let urlrequest = URLRequest(url: URL(string: "https://www.httpbin.org/")!)
        let response = http()(urlrequest)
        XCTAssertNotNil(response)
        if case .success(let response, _) = response {
            XCTAssertEqual(response.statusCode, 200)
        } else {
            XCTFail()
        }
    }
    
    func testBuildHTTPResponseWith421() {
        let urlrequest = URLRequest(url: URL(string: "https://www.httpbin.org/")!)
        let response = http(421)(urlrequest)
        XCTAssertNotNil(response)
        if case .success(let response, _) = response {
            XCTAssertEqual(response.statusCode, 421)
        } else {
            XCTFail()
        }
    }
    
    func testBuildFailureResponse() {
        let yaError = NSError(domain: "YetAnotherTestError", code: 0, userInfo: nil)
        let urlrequest = URLRequest(url: URL(string: "https://www.httpbin.org/")!)
        let response = failure(yaError)(urlrequest)
        if case .failure(let error) = response {
            XCTAssertEqual(error, yaError)
        } else {
            XCTFail()
        }
    }
    
    func testBuildJSONStringResponse() {
        let stringContent = "{\"hello\": \"world\"}"
        let urlrequest = URLRequest(url: URL(string: "https://www.httpbin.org/")!)
        let response = jsonString(stringContent)(urlrequest)
        XCTAssertNotNil(response)
        if case .success(let response, let content) = response {
            XCTAssertEqual(response.statusCode, 200)
            XCTAssertEqual(response.mimeType, "application/json")
            XCTAssertEqual(response.textEncodingName, "utf-8")
            XCTAssertEqual(content, StubContent.data(stringContent.data(using: String.Encoding.utf8)!))
        } else {
            XCTFail()
        }
    }
    
    func testBuildJSONResponse() {
        let stringContent = "{\"hello\":\"world\"}"
        let urlrequest = URLRequest(url: URL(string: "https://www.httpbin.org/")!)
        let response = json(["hello": "world"])(urlrequest)
        XCTAssertNotNil(response)
        if case .success(let response, let content) = response {
            XCTAssertEqual(response.statusCode, 200)
            XCTAssertEqual(response.mimeType, "application/json")
            XCTAssertEqual(response.textEncodingName, "utf-8")
            XCTAssertEqual(content, StubContent.data(stringContent.data(using: String.Encoding.utf8)!))
            if case .data(let data) = content {
                let body = String(data: data, encoding: String.Encoding.utf8)
                XCTAssertEqual(body, stringContent)
            } else {
                XCTFail()
            }
        } else {
            XCTFail()
        }
    }
    
    func testBuildJSONDataResponse() {
        let jsonBytes = "{\"hello\":\"world\"}".data(using: String.Encoding.utf8)!
        let urlrequest = URLRequest(url: URL(string: "https://www.httpbin.org/")!)
        let response = jsonData(jsonBytes)(urlrequest)
        XCTAssertNotNil(response)
        if case .success(let response, let content) = response {
            XCTAssertEqual(response.statusCode, 200)
            XCTAssertEqual(response.mimeType, "application/json")
            XCTAssertEqual(response.textEncodingName, "utf-8")
            XCTAssertEqual(content, StubContent.data(jsonBytes))
        } else {
            XCTFail()
        }
    }
}
