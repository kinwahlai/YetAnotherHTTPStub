//
//  MatcherTests.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/9/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation
import XCTest
@testable import YetAnotherHTTPStub

class MatchersTests: XCTestCase {
    var urlrequest: URLRequest!
    var invalidRequest: URLRequest!
    var urlWithPathRequest: URLRequest!
    var urlWithQueryRequest: URLRequest!
    var urlWithBracketsRequest: URLRequest!
    var urlWithPlusRequest: URLRequest!
    var forInvalidQueryTestRequest: URLRequest!
    override func setUp() {
        super.setUp()
        urlrequest = URLRequest(url: URL(string: "https://www.httpbin.org/")!)
        urlrequest.httpMethod = "POST"
        invalidRequest = URLRequest(url: URL(string: "https://www.httpbin.org/")!)
        invalidRequest.url = nil
        urlWithPathRequest = URLRequest(url: URL(string: "https://www.httpbin.org/user-agent")!)
        urlWithQueryRequest = URLRequest(url: URL(string: "https://www.httpbin.org/get?show_env=1&page=2")!)
        urlWithQueryRequest.httpMethod = "GET"
        urlWithBracketsRequest = URLRequest(url: URL(string: "https://www.httpbin.org/get?show_env[]=1")!)
        urlWithBracketsRequest.httpMethod = "GET"
        urlWithPlusRequest = URLRequest(url: URL(string: "https://www.httpbin.org/get?query+test=1")!)
        urlWithPlusRequest.httpMethod = "GET"
        forInvalidQueryTestRequest = URLRequest(url: URL(string: "https://www.httpbin.org/get?show_env=1&page=a")!)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testEverythingMatcher() {
        XCTAssertTrue(everything(urlrequest))
    }
    
    func testNothingMatcher() {
        XCTAssertFalse(nothing(urlrequest))
    }
    
    func testURICanHandleInvalidURLRequest() {
        XCTAssertFalse(uri("https://www.httpbin.org/")(invalidRequest))
    }
    
    // full url
    func testFullURLMismatch() {
        XCTAssertFalse(uri("https://www.google.org/")(urlrequest))
        XCTAssertFalse(uri("https://www.httpbin.org")(urlrequest))
    }
    
    func testFullURLMatchesExactly() {
        XCTAssertTrue(uri("https://www.httpbin.org/")(urlrequest))
    }
    
    func testFullURLWithWildcardMatches() {
        XCTAssertTrue(uri("https://www.httpbin.org/get?show_env=\\d&page=\\d")(urlWithQueryRequest))
    }
    
    func testFullURLWithWildcardMismatch() {
        XCTAssertFalse(uri("https://www.httpbin.org/get?show_env=\\d&page=\\d")(forInvalidQueryTestRequest))
    }
    
    // path only
    func testFullPathMatchesExactly() {
        XCTAssertTrue(uri("/user-agent")(urlWithPathRequest))
    }
    
    func testFullPathMismatch() {
        XCTAssertFalse(uri("/ip")(urlWithPathRequest))
    }
    
    func testFullPathWithWildcardMatches() {
        XCTAssertTrue(uri("/get?show_env=\\d&page=\\d")(urlWithQueryRequest))
    }
    
    func testFullPathWithWildcardMismatch() {
        XCTAssertFalse(uri("/get?show_env=\\d&page=\\d")(forInvalidQueryTestRequest))
    }
    
    // test the method too
    func testMethodWithFullURLMatchesExactly() {
        XCTAssertTrue(http(.post, uri: "https://www.httpbin.org/")(urlrequest))
    }

    func testMethodWithFullURLMismatch() {
        XCTAssertFalse(http(.get, uri: "https://www.httpbin.org/")(urlrequest))
    }
    // full path
    func testMethodWithPathAndWildcardMatches() {
        XCTAssertTrue(http(.get, uri: "/get?show_env=\\d&page=\\d")(urlWithQueryRequest))
    }

    func testMethodWithPathAndWildcardMismatch() {
        XCTAssertFalse(http(.patch, uri: "/get?show_env=\\d&page=\\d")(urlWithQueryRequest))
    }
    // special characters
    func testMethodWithBracketCharacters() {
        XCTAssertTrue(http(.get, uri: "/get?show_env[]=1")(urlWithBracketsRequest))
    }
    func testMethodWithPlusSign() {
        XCTAssertTrue(http(.get, uri: "/get?query+test=1")(urlWithPlusRequest))
    }
}
