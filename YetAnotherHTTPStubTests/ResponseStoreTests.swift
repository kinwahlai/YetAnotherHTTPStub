//
//  ResponseStoreTests.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/23/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import XCTest
@testable import YetAnotherHTTPStub

class ResponseStoreTests: XCTestCase {
    var httpbin: URLRequest!
    override func setUp() {
        super.setUp()
        httpbin = URLRequest(url: URL(string: "https://www.httpbin.org/")!)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testStoreHasNoResponseOnInit() {
        let store = ResponseStore()
        XCTAssertTrue(store.isEmpty)
        XCTAssertEqual(store.responseCount, 0)
    }
    
    func testStoreReturnFailureResponseIfEmpty() {
        let store = ResponseStore()
        let stubResponse = store.popResponse(for: httpbin)
        switch stubResponse.builder!(httpbin) {
        case .failure(let error):
            XCTAssertEqual(error.localizedDescription, "There isn't any(more) response for this request https://www.httpbin.org/")
        case .success(_, _):
            XCTFail()
        }
    }

    func testStoreReturnFailureResponseIfFirstResponseFoundIsPartial() {
        let partialResponse = StubResponse()
        let store = ResponseStore([partialResponse])
        let stubResponse = store.popResponse(for: httpbin)
        switch stubResponse.builder!(httpbin) {
        case .failure(let error):
            XCTAssertEqual(error.localizedDescription, "Cannot process partial response for this request https://www.httpbin.org/")
        case .success(_, _):
            XCTFail()
        }
    }
    
    func testStoreReturnFirstResponse() {
        let param = StubResponse.Parameter()
        let response = StubResponse().setup(with: param)
        let store = ResponseStore([response])
        let stubResponse = store.popResponse(for: httpbin)
        XCTAssertEqual(stubResponse, response)
    }

    func testAddResponseToStore() {
        let delay: TimeInterval = 5
        let customQueue = DispatchQueue(label: "custom.queue")
        let param = StubResponse.Parameter()
                    .setResponseDelay(delay)
                    .setBuilder(builder: http())
        
        let store = ResponseStore()
        store.addResponse(queue: customQueue)
        store.addResponse(with: param)
        
        let stubResponse = store.popResponse(for: httpbin)
        switch stubResponse.builder!(httpbin) {
        case .failure(_):
            XCTFail()
        case .success(let response, _):
            XCTAssertEqual(response.statusCode, 200)
            XCTAssertEqual(stubResponse.queue, customQueue)
            XCTAssertEqual(stubResponse.delay, delay)
        }
    }
    
    func testAddRepeatableResponseToStore() {
        let delay: TimeInterval = 0
        let param = StubResponse.Parameter()
                    .setResponseDelay(delay)
                    .setRepeatable(3)
                    .setBuilder(builder: http())
        
        let store = ResponseStore()
        store.addResponse(with: param)
        _ = store.popResponse(for: httpbin)
        _ = store.popResponse(for: httpbin)
        let stubResponse = store.popResponse(for: httpbin)
        switch stubResponse.builder!(httpbin) {
        case .failure(_):
            XCTFail()
        case .success(let response, _):
            XCTAssertEqual(response.statusCode, 200)
        }
        
        // become failure due to no more reponse
        let failure = store.popResponse(for: httpbin)
        switch failure.builder!(httpbin) {
        case .failure(let error):
            XCTAssertEqual(error.localizedDescription, "There isn't any(more) response for this request https://www.httpbin.org/")
        case .success(_, _):
            XCTFail()
        }
    }
}
