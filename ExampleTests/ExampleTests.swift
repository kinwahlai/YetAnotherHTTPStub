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
}
