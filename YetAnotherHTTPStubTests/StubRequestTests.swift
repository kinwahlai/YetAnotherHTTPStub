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
    var httpbin: URLRequest!
    var customQueue: DispatchQueue!
    override func setUp() {
        super.setUp()
        trueMatcher = { _ in
            return true
        }
        falseMatcher = { _ in
            return false
        }
        httpbin = URLRequest(url: URL(string: "https://www.httpbin.org/")!)
        customQueue = DispatchQueue(label: "custom.queue")
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
        XCTAssertNotNil(stubRequest.responseStore)
        XCTAssertTrue(stubRequest.responseStore.isEmpty)
    }

    func testRequestHasMultipleStubResponse() {
        let stubRequest = StubRequest(trueMatcher)
        stubRequest
            .thenResponse(configurator: { param in
                param.setBuilder(builder: http(200, headers: [:], content: .noContent))
            })
            .thenResponse(configurator: { param in
                param.setBuilder(builder: http(404, headers: [:], content: .noContent))
            })
        
        XCTAssertEqual(stubRequest.responseStore.responseCount, 2)
    }
    
    func testSetupMultipleStubResponseWithParameter() {
        let stubRequest = StubRequest(trueMatcher)
        stubRequest
            .thenResponse(configurator: { param in
                param.setBuilder(builder: http(200, headers: [:], content: .noContent))
            })
            .thenResponse(configurator: { param in
                param.setBuilder(builder: http(404, headers: [:], content: .noContent))
            })
        
        XCTAssertEqual(stubRequest.responseStore.responseCount, 2)
    }

    func testReturnFailureResponseIfDeveloperDidntSetResponse() {
        let stubRequest = StubRequest(trueMatcher)
        let stubResponse = stubRequest.popResponse(for: httpbin)
        switch stubResponse!.builder!(httpbin) {
        case .failure(let error):
            XCTAssertEqual(error.message, "There isn't any(more) response for this request https://www.httpbin.org/")
        case .success(_, _):
            XCTFail()
        }
    }
    
    func testReturnFailureResponseIfResponseStackBecomeEmpty() {
        let stubRequest = StubRequest(trueMatcher)
        stubRequest.thenResponse(configurator: { param in
            param.setBuilder(builder: jsonString("hello1"))
        })
        _ = stubRequest.popResponse(for: httpbin)
        let stubResponse = stubRequest.popResponse(for: httpbin)
        switch stubResponse!.builder!(httpbin) {
        case .failure(let error):
            XCTAssertEqual(error.message, "There isn't any(more) response for this request https://www.httpbin.org/")
        case .success(_, _):
            XCTFail()
        }
    }

    func testNoResponsesIfRequestNotMatch() {
        let stubRequest = StubRequest(falseMatcher)
        stubRequest.thenResponse(configurator: { param in
            param.setBuilder(builder: http(200, headers: [:], content: .noContent))
        })
        let response = stubRequest.popResponse(for: httpbin)
        XCTAssertNil(response)
    }
    
    func testFirstResponsesIfRequestMatching() {
        let stubRequest = StubRequest(trueMatcher)
        stubRequest.thenResponse(configurator: { param in
            param.setBuilder(builder: jsonString("hello"))
        })
        let stubResponse = stubRequest.popResponse(for: httpbin)
        switch stubResponse!.builder!(httpbin) {
        case .failure(_):
            XCTFail()
        case .success(let response, _):
            XCTAssertNotNil(response)
        }
    }

    func testUseFirstResponseQueueUntilSwitchToOtherQueue() {
        let stubRequest = StubRequest(trueMatcher)
        stubRequest
            .thenResponse(configurator: { param in
                param.setBuilder(builder: jsonString("hello"))
            })
            .thenResponse(configurator: { param in
                param.setBuilder(builder: jsonString("world"))
            })
        let response1 = stubRequest.popResponse(for: httpbin)
        let response2 = stubRequest.popResponse(for: httpbin)
        XCTAssertNotNil(response1)
        XCTAssertNotNil(response2)
        XCTAssertEqual(response1?.queue, response2?.queue)
    }

    func testReturnFailureResponseForPartialResponse() {
        let stubRequest = StubRequest(trueMatcher)
        stubRequest
            .responseOn(queue: customQueue)
        let stubResponse = stubRequest.popResponse(for: httpbin)
        switch stubResponse!.builder!(httpbin) {
        case .failure(let error):
            XCTAssertEqual(error.message, "Cannot process partial response for this request https://www.httpbin.org/")
        case .success(_, _):
            XCTFail()
        }
    }
    
    func testPartialResponseWillBecomeFullOnceAssignBuilder() {
        let stubRequest = StubRequest(trueMatcher)
        stubRequest
            .responseOn(queue: customQueue)
            .thenResponse(configurator: { param in
                param.setBuilder(builder: jsonString("hello"))
            })
        let stubResponse = stubRequest.popResponse(for: httpbin)
        XCTAssertNotNil(stubResponse)
        switch stubResponse!.builder!(httpbin) {
        case .failure(_):
            XCTFail()
        case .success(let response, _):
            XCTAssertEqual(response.statusCode, 200)
            XCTAssertEqual(stubResponse?.queue, customQueue)
        }
    }
    
    func testUseLastQueueUntilItSwitch() {
        let stubRequest = StubRequest(trueMatcher)
        stubRequest
            .thenResponse(configurator: { param in
                param.setBuilder(builder: jsonString("hello"))
            })
            .thenResponse(configurator: { param in
                param.setBuilder(builder: jsonString("world"))
            })
            .responseOn(queue: customQueue)
            .thenResponse(configurator: { param in
                param.setBuilder(builder: jsonString("?"))
            })
            .thenResponse(configurator: { param in
                param.setBuilder(builder: jsonString("!"))
            })
        let response1 = stubRequest.popResponse(for: httpbin)
        let response2 = stubRequest.popResponse(for: httpbin)
        let response3 = stubRequest.popResponse(for: httpbin)
        let response4 = stubRequest.popResponse(for: httpbin)
        XCTAssertNotNil(response1)
        XCTAssertNotNil(response2)
        XCTAssertNotNil(response3)
        XCTAssertNotNil(response4)

        XCTAssertEqual(response1?.queue, response2?.queue)
        XCTAssertEqual(response1?.queue.label, "kinwahlai.stubresponse.queue")
        XCTAssertNotEqual(response1?.queue, response3?.queue)
        
        XCTAssertEqual(response3?.queue, response4?.queue)
        XCTAssertEqual(response3?.queue.label, "custom.queue")
        XCTAssertEqual(response3?.queue, customQueue)
    }
    
    func testDefaultDelayIsZero() {
        let stubRequest = StubRequest(trueMatcher)
        stubRequest
            .thenResponse(configurator: { param in
                param.setBuilder(builder: jsonString("hello"))
            })
        let response1 = stubRequest.popResponse(for: httpbin)
        XCTAssertEqual(response1?.delay, 0)
    }

    func testSetDelayForTheResponse() {
        let stubRequest = StubRequest(trueMatcher)
        stubRequest
            .thenResponse(configurator: { param in
                param.setBuilder(builder: jsonString("hello"))
                    .setResponseDelay(5)
            })
        let response1 = stubRequest.popResponse(for: httpbin)
        XCTAssertEqual(response1?.delay, 5)
    }
    
    func testSetRepeatableForTheResponse() {
        let stubRequest = StubRequest(trueMatcher)
        stubRequest
            .thenResponse(configurator: { param in
                param.setBuilder(builder: jsonString("hello"))
                    .setResponseDelay(0)
                    .setRepeatable(2)
            })
        let response1 = stubRequest.popResponse(for: httpbin)
        XCTAssertEqual(response1?.repeatCount, 1)
        let response2 = stubRequest.popResponse(for: httpbin)
        XCTAssertEqual(response2?.repeatCount, 0)
    }
}
