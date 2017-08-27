//
//  ExampleTests.swift
//  ExampleTests
//
//  Created by Darren Lai on 7/15/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import XCTest
import Alamofire
import YetAnotherHTTPStub
@testable import Example

class ExampleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSimpleExample() {
        let bundle = Bundle(for: ExampleTests.self)
        guard let path = bundle.path(forResource: "GET", ofType: "json"), let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { XCTFail(); return }
        
        YetAnotherURLProtocol.stubHTTP { (session) in
            session.whenRequest(matcher: http(.get, uri: "/get"))
            .thenResponse(responseBuilder: jsonData(data, status: 200))
        }
        
        let expect = expectation(description: "")
        Alamofire.request("https://httpbin.org/get").responseJSON { (response) in
            XCTAssertTrue(response.result.isSuccess)
            let dict = response.result.value as? [String: Any]
            XCTAssertNotNil(dict)
            let originIp = dict!["origin"] as! String
            XCTAssertEqual(originIp, "9.9.9.9")
            expect.fulfill()
        }
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testMultipleRequestExample() {
        let bundle = Bundle(for: ExampleTests.self)
        guard let path = bundle.path(forResource: "GET", ofType: "json"), let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { XCTFail(); return }
        let expect1 = expectation(description: "1")
        let expect2 = expectation(description: "2")
        
        YetAnotherURLProtocol.stubHTTP { (session) in
            session.whenRequest(matcher: http(.get, uri: "/get"))
                .thenResponse(responseBuilder: jsonData(data, status: 200))
            
            session.whenRequest(matcher: http(.get, uri: "/get?show_env=1&page=1"))
            .thenResponse(responseBuilder: jsonString("{\"args\":{\"page\": 1,\"show_env\": 1}}", status: 200))
        }
        
        Alamofire.request("https://httpbin.org/get").responseJSON { (response) in
            XCTAssertTrue(response.result.isSuccess)
            XCTAssertFalse(response.result.isFailure)
            let dict = response.result.value as? [String: Any]
            XCTAssertNotNil(dict)
            let originIp = dict!["origin"] as! String
            XCTAssertEqual(originIp, "9.9.9.9")
            expect1.fulfill()
        }
        
        Alamofire.request("https://httpbin.org/get?show_env=1&page=1").responseJSON { (response) in
            XCTAssertTrue(response.result.isSuccess)
            XCTAssertFalse(response.result.isFailure)
            let dict = response.result.value as? [String: Any]
            let args = dict!["args"] as! [String: Any]
            XCTAssertNotNil(args)
            XCTAssertEqual(args["show_env"] as! Int, 1)
            expect2.fulfill()
        }
        wait(for: [expect1, expect2], timeout: 5)
    }
    
    func testMultipleResponseExample() {
        let expect1 = expectation(description: "1")
        let expect2 = expectation(description: "2")
        let expect3 = expectation(description: "3")
        
        YetAnotherURLProtocol.stubHTTP { (session) in
            session.whenRequest(matcher: http(.get, uri: "/polling"))
                .thenResponse(responseBuilder: jsonString("{\"status\": 0}", status: 200))
                .thenResponse(responseBuilder: jsonString("{\"status\": 0}", status: 200))
                .thenResponse(responseBuilder: jsonString("{\"status\": 1}", status: 200))
        }
        
        let response3: (DataResponse<Any>) -> Void = { (response) in
            XCTAssertTrue(response.result.isSuccess)
            XCTAssertFalse(response.result.isFailure)
            let dict = response.result.value as! [String: Int]
            XCTAssertEqual(dict["status"], 1)
            expect3.fulfill()
        }
        let response2: (DataResponse<Any>) -> Void = { [response3] (response) in
            XCTAssertTrue(response.result.isSuccess)
            XCTAssertFalse(response.result.isFailure)
            expect2.fulfill()
            self.httpRequest(forURL: "https://httpbin.org/polling", closure: response3)
        }
        let response1: (DataResponse<Any>) -> Void = { [response2] (response) in
            XCTAssertTrue(response.result.isSuccess)
            XCTAssertFalse(response.result.isFailure)
            expect1.fulfill()
            self.httpRequest(forURL: "https://httpbin.org/polling", closure: response2)
        }
        httpRequest(forURL: "https://httpbin.org/polling", closure: response1)
     
        wait(for: [expect1, expect2, expect3], timeout: 5)
    }
    
    func testSimpleExampleWithDelay() {
        let delay: TimeInterval = 5
        let bundle = Bundle(for: ExampleTests.self)
        guard let path = bundle.path(forResource: "GET", ofType: "json"), let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { XCTFail(); return }
        
        YetAnotherURLProtocol.stubHTTP { (session) in
            session.whenRequest(matcher: http(.get, uri: "/get"))
                .thenResponse(withDelay: delay, responseBuilder: jsonData(data, status: 200))
        }
        
        let expect = expectation(description: "")
        Alamofire.request("https://httpbin.org/get").responseJSON { (response) in
            XCTAssertTrue(response.result.isSuccess)
            XCTAssertFalse(response.result.isFailure)
            expect.fulfill()
        }
        waitForExpectations(timeout: delay + 1) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testRequestFailedIfStubSessionSetupIncomplete() {
        let customQueue = DispatchQueue(label: "custom.queue")
        YetAnotherURLProtocol.stubHTTP { (session) in
            session.whenRequest(matcher: http(.get, uri: "/noResponse"))

            session.whenRequest(matcher: http(.get, uri: "/partialResponse"))
                .responseOn(queue: customQueue)
        }
        
        let expect1 = expectation(description: "1")
        let expect2 = expectation(description: "2")
        
        let response2: (DataResponse<Any>) -> Void = { (response) in
            if case .failure(let error) = response.result {
                XCTAssertEqual((error as! StubError).message, "Cannot process partial response for this request https://httpbin.org/partialResponse")
            } else {
                XCTFail()
            }
            expect2.fulfill()
        }
        let response1: (DataResponse<Any>) -> Void = { (response) in
            if case .failure(let error) = response.result {
                XCTAssertEqual((error as! StubError).message, "There isn't any(more) response for this request https://httpbin.org/noResponse")
            } else {
                XCTFail()
            }
            expect1.fulfill()
        }
        
        httpRequest(forURL: "https://httpbin.org/noResponse", closure: response1)
        httpRequest(forURL: "https://httpbin.org/partialResponse", closure: response2)
        
        wait(for: [expect1, expect2], timeout: 5)
    }
    
    func testExampleUsingFileContentBuilder() {
        guard let filePath: URL = Bundle(for: ExampleTests.self).url(forResource: "GET", withExtension: "json") else { XCTFail(); return }
        
        YetAnotherURLProtocol.stubHTTP { (session) in
            session.whenRequest(matcher: http(.get, uri: "/get"))
                .thenResponse(responseBuilder: jsonFile(filePath)) // or fileContent
        }
        
        let expect = expectation(description: "")
        Alamofire.request("https://httpbin.org/get").responseJSON { (response) in
            XCTAssertTrue(response.result.isSuccess)
            let dict = response.result.value as? [String: Any]
            XCTAssertNotNil(dict)
            let originIp = dict!["origin"] as! String
            XCTAssertEqual(originIp, "9.9.9.9")
            expect.fulfill()
        }
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testRepeatableResponseExample() {
        let expect1 = expectation(description: "1")
        let expect2 = expectation(description: "2")
        let expect3 = expectation(description: "3")
        
        YetAnotherURLProtocol.stubHTTP { (session) in
            session.whenRequest(matcher: http(.get, uri: "/polling"))
                .thenResponse(repeat: 2, responseBuilder: jsonString("{\"status\": 0}", status: 200))
                .thenResponse(responseBuilder: jsonString("{\"status\": 1}", status: 200))
        }
        
        let response3: (DataResponse<Any>) -> Void = { (response) in
            XCTAssertTrue(response.result.isSuccess)
            XCTAssertFalse(response.result.isFailure)
            let dict = response.result.value as! [String: Int]
            XCTAssertEqual(dict["status"], 1)
            expect3.fulfill()
        }
        let response2: (DataResponse<Any>) -> Void = { [response3] (response) in
            XCTAssertTrue(response.result.isSuccess)
            XCTAssertFalse(response.result.isFailure)
            expect2.fulfill()
            self.httpRequest(forURL: "https://httpbin.org/polling", closure: response3)
        }
        let response1: (DataResponse<Any>) -> Void = { [response2] (response) in
            XCTAssertTrue(response.result.isSuccess)
            XCTAssertFalse(response.result.isFailure)
            expect1.fulfill()
            self.httpRequest(forURL: "https://httpbin.org/polling", closure: response2)
        }
        httpRequest(forURL: "https://httpbin.org/polling", closure: response1)
        
        wait(for: [expect1, expect2, expect3], timeout: 5)
    }
    
    func testGetNotifyAfterStubResponseReplied() {
        var gotNotify: String? = nil
        
        YetAnotherURLProtocol.stubHTTP { (session) in
            session.whenRequest(matcher: http(.get, uri: "/get"))
                .thenResponse(configurator: { (param) in
                    param.setResponseDelay(2)
                        .setBuilder(builder: jsonString("{\"hello\":\"world\"}", status: 200))
                        .setPostReply {
                            gotNotify = "post reply notification"
                        }
                })
        }
        
        let expect = expectation(description: "")
        Alamofire.request("https://httpbin.org/get").responseJSON { (response) in
            expect.fulfill()
        }
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error)
        }
        
        XCTAssertEqual(gotNotify, "post reply notification")
    }
    
    fileprivate func httpRequest(forURL urlstring: String, closure: @escaping ((DataResponse<Any>) -> Void)) {
        Alamofire.request(urlstring).responseJSON(completionHandler: closure)
    }
}
