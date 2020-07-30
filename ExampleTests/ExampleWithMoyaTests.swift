//
//  ExampleWithMoyaTests.swift
//  ExampleTests
//
//  Created by Darren Lai on 7/30/20.
//  Copyright © 2020 KinWahLai. All rights reserved.
//

import XCTest
import YetAnotherHTTPStub
@testable import Example

class ExampleWithMoyaTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testSimpleExample() throws {
        let bundle = Bundle(for: ExampleWithMoyaTests.self)
        guard let path = bundle.path(forResource: "GET", ofType: "json"), let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { XCTFail(); return }
        
        YetAnotherURLProtocol.stubHTTP { (session) in
            session.whenRequest(matcher: http(.get, uri: "/get"))
            .thenResponse(responseBuilder: jsonData(data, status: 200))
        }
        
        let expect = expectation(description: "")
        let service = ServiceUsingMoya()
        
        service.getRequest { (dict, _) in
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
        let bundle = Bundle(for: ExampleWithMoyaTests.self)
        guard let path = bundle.path(forResource: "GET", ofType: "json"), let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { XCTFail(); return }
        let expect1 = expectation(description: "1")
        let expect2 = expectation(description: "2")
        
        YetAnotherURLProtocol.stubHTTP { (session) in
            session.whenRequest(matcher: http(.get, uri: "/get"))
                .thenResponse(responseBuilder: jsonData(data, status: 200))
            
            session.whenRequest(matcher: http(.get, uri: "/get?show_env=1&page=1"))
            .thenResponse(responseBuilder: jsonString("{\"args\":{\"page\": 1,\"show_env\": 1}}", status: 200))
        }
        
        let service = ServiceUsingMoya()
        service.getRequest { (dict, _) in
            XCTAssertNotNil(dict)
            let originIp = dict!["origin"] as! String
            XCTAssertEqual(originIp, "9.9.9.9")
            expect1.fulfill()
        }
        
        service.getRequest(with: "https://httpbin.org/get?show_env=1&page=1") { (dict, _) in
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
        let service = ServiceUsingMoya()
        
        let response3: HttpbinService.ResquestResponse = { (dict, _) in
            let dictInt = dict as! [String: Int]
            XCTAssertEqual(dictInt["status"], 1)
            expect3.fulfill()
        }
        let response2: HttpbinService.ResquestResponse = { [response3] (dict, _) in
            expect2.fulfill()
            service.getRequest(with: "https://httpbin.org/polling", response3)
        }
        let response1: HttpbinService.ResquestResponse = { [response2] (dict, _) in
            expect1.fulfill()
            service.getRequest(with: "https://httpbin.org/polling", response2)
        }
        service.getRequest(with: "https://httpbin.org/polling", response1)
     
        wait(for: [expect1, expect2, expect3], timeout: 5)
    }
    
    func testSimpleExampleWithDelay() {
        let delay: TimeInterval = 5
        let bundle = Bundle(for: ExampleWithMoyaTests.self)
        guard let path = bundle.path(forResource: "GET", ofType: "json"), let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { XCTFail(); return }
        
        YetAnotherURLProtocol.stubHTTP { (session) in
            session.whenRequest(matcher: http(.get, uri: "/get"))
                .thenResponse(withDelay: delay, responseBuilder: jsonData(data, status: 200))
        }
        let service = ServiceUsingMoya()
        let expect = expectation(description: "")
        service.getRequest { (dict, error) in
            XCTAssertNotNil(dict)
            XCTAssertNil(error)
            expect.fulfill()
        }
        waitForExpectations(timeout: delay + 1) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testExampleUsingFileContentBuilder() {
        guard let filePath: URL = Bundle(for: ExampleWithMoyaTests.self).url(forResource: "GET", withExtension: "json") else { XCTFail(); return }
        
        YetAnotherURLProtocol.stubHTTP { (session) in
            session.whenRequest(matcher: http(.get, uri: "/get"))
                .thenResponse(responseBuilder: jsonFile(filePath)) // or fileContent
        }
        let service = ServiceUsingMoya()
        let expect = expectation(description: "")
        service.getRequest { (dict, error) in
            XCTAssertNil(error)
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
        let service = ServiceUsingMoya()
        
        let response3: HttpbinService.ResquestResponse = { (dict, error) in
            XCTAssertNotNil(dict)
            XCTAssertNil(error)
            let dictInt = dict as! [String: Int]
            XCTAssertEqual(dictInt["status"], 1)
            expect3.fulfill()
        }
        let response2: HttpbinService.ResquestResponse = { [response3] (dict, error) in
            XCTAssertNotNil(dict)
            XCTAssertNil(error)
            expect2.fulfill()
            service.getRequest(with: "https://httpbin.org/polling", response3)
        }
        let response1: HttpbinService.ResquestResponse = { [response2] (dict, error) in
            XCTAssertNotNil(dict)
            XCTAssertNil(error)
            expect1.fulfill()
            service.getRequest(with: "https://httpbin.org/polling", response2)
        }
        service.getRequest(with: "https://httpbin.org/polling", response1)
        
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
        let service = ServiceUsingMoya()
        let expect = expectation(description: "")
        service.getRequest { (dict, error) in
            expect.fulfill()
        }
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error)
        }
        
        XCTAssertEqual(gotNotify, "post reply notification")
    }
}
