//
//  StubResponseTests.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/15/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import XCTest
@testable import YetAnotherHTTPStub

class FakeURLProtocol: URLProtocol {}

class URLProtocolClientSpy: NSObject, URLProtocolClient {
    var clientDidReceiveResponse: Bool = false
    var clientDidLoadData: Bool = false
    var clientDidFailedWithError: Bool = false
    var clientDidFinishLoading: Bool = false
    var dataLoaded: Data?
    var response: HTTPURLResponse?
    var cacheStoragePolicy: URLCache.StoragePolicy?
    var error: Error?

    public func urlProtocol(_ protocol: URLProtocol, didReceive response: URLResponse, cacheStoragePolicy policy: URLCache.StoragePolicy) {
        clientDidReceiveResponse = true
        cacheStoragePolicy = policy
        self.response = response as? HTTPURLResponse
    }
    
    public func urlProtocol(_ protocol: URLProtocol, didLoad data: Data) {
        clientDidLoadData = true
        dataLoaded = data
    }
    
    
    public func urlProtocol(_ protocol: URLProtocol, didFailWithError error: Error) {
        clientDidFailedWithError = true
        self.error = error
    }
    
    public func urlProtocolDidFinishLoading(_ protocol: URLProtocol) {
        clientDidFinishLoading = true
    }
    
    public func urlProtocol(_ protocol: URLProtocol, wasRedirectedTo request: URLRequest, redirectResponse: URLResponse) {}
    public func urlProtocol(_ protocol: URLProtocol, cachedResponseIsValid cachedResponse: CachedURLResponse) {}
    public func urlProtocol(_ protocol: URLProtocol, didReceive challenge: URLAuthenticationChallenge) {}
    public func urlProtocol(_ protocol: URLProtocol, didCancel challenge: URLAuthenticationChallenge) {}
}

class StubResponseUnderTest: StubResponse {
    var customQueueSet: Bool = false
    
    override init(queue: DispatchQueue?) {
        self.customQueueSet = true
        super.init(queue: queue)
    }
}

class StubResponseTests: XCTestCase {
    var client: URLProtocolClientSpy!
    var request: URLRequest!
    
    override func setUp() {
        super.setUp()
        client = URLProtocolClientSpy()
        request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        request.httpMethod = "GET"
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testErrorResponse() {
        let request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        let fakeProtocol = FakeURLProtocol(request: request, cachedResponse: nil, client: client)
        let expect = expectation(description: "error")
        let param = StubResponse.Parameter()
                    .setBuilder(builder: http(404))
                    .setPostReply {
                        expect.fulfill()
                    }

        let response = StubResponse().setup(with: param)
        response.reply(via: fakeProtocol)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
        XCTAssertTrue(client.clientDidReceiveResponse)
        XCTAssertFalse(client.clientDidLoadData)
        let receivedResponse = client.response
        XCTAssertNotNil(receivedResponse)
        XCTAssertEqual(receivedResponse?.statusCode, 404)
        XCTAssertTrue(client.clientDidFinishLoading)
    }

    func testPostResponse() {
        var request = URLRequest(url: URL(string: "https://httpbin.org/post")!)
        request.httpMethod = "POST"
        let fakeProtocol = FakeURLProtocol(request: request, cachedResponse: nil, client: client)
        let expect = expectation(description: "post")
        let param = StubResponse.Parameter()
                    .setBuilder(builder: http(200))
                    .setPostReply {
                        expect.fulfill()
                    }
        
        let response = StubResponse().setup(with: param)
        response.reply(via: fakeProtocol)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
        XCTAssertTrue(client.clientDidReceiveResponse)
        XCTAssertFalse(client.clientDidLoadData)
        let receivedResponse = client.response
        XCTAssertNotNil(receivedResponse)
        XCTAssertEqual(receivedResponse?.statusCode, 200)
        XCTAssertTrue(client.clientDidFinishLoading)
    }

    func testGetResponse() {
        let fakeProtocol = FakeURLProtocol(request: request, cachedResponse: nil, client: client)
        let responseBuilder: Builder = http(200, headers: ["Content-Type": "application/json; charset=utf-8"], content: .data("hello".data(using: String.Encoding.utf8)!))
        let expect = expectation(description: "get")
        let param = StubResponse.Parameter()
                    .setBuilder(builder: responseBuilder)
                    .setPostReply {
                        expect.fulfill()
                    }
        
        let response = StubResponse().setup(with: param)
        response.reply(via: fakeProtocol)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
        XCTAssertTrue(client.clientDidReceiveResponse)
        XCTAssertTrue(client.clientDidLoadData)
        XCTAssertEqual(client.dataLoaded, "hello".data(using: String.Encoding.utf8)!)
        let receivedResponse = client.response
        XCTAssertNotNil(receivedResponse)
        XCTAssertEqual(receivedResponse?.statusCode, 200)
        XCTAssertEqual(receivedResponse?.mimeType, "application/json")
        XCTAssertEqual(receivedResponse?.textEncodingName, "utf-8")
        XCTAssertTrue(client.clientDidFinishLoading)
    }
    
    func testFailureResponse() {
        let fakeProtocol = FakeURLProtocol(request: request, cachedResponse: nil, client: client)
        let responseBuilder: Builder = failure(StubError.exhaustedResponse(request))
        let expect = expectation(description: "get")
        let param = StubResponse.Parameter()
                    .setBuilder(builder: responseBuilder)
                    .setPostReply {
                        expect.fulfill()
                    }
        
        let response = StubResponse().setup(with: param)
        response.reply(via: fakeProtocol)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
        XCTAssertTrue(client.clientDidFailedWithError)
    }
    
    func testCreateAPartialResponseWithQueue() {
        let customQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        let response = StubResponseUnderTest(queue: customQueue)
        XCTAssertTrue(response.customQueueSet)
        XCTAssertTrue(response.isPartial)
    }

    func testPartialResponseWillNotBeProcess() {
        let fakeProtocol = FakeURLProtocol(request: request, cachedResponse: nil, client: client)
        
        let customQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        let response = StubResponseUnderTest(queue: customQueue)
        
        response.reply(via: fakeProtocol)
        
        XCTAssertFalse(client.clientDidReceiveResponse)
        XCTAssertFalse(client.clientDidLoadData)
    }
    
    func testSetDelayToStubResponse() {
        let param = StubResponse.Parameter()
                    .setResponseDelay(5)
        XCTAssertEqual(StubResponse().setup(with: param).delay, 5)
    }
    
    func testGetResponseAfterDelay() {
        let delay: TimeInterval = 2
        let fakeProtocol = FakeURLProtocol(request: request, cachedResponse: nil, client: client)
        let expect = expectation(description: "get")
        let param = StubResponse.Parameter()
                    .setResponseDelay(delay)
                    .setBuilder(builder: http(200))
                    .setPostReply {
                        expect.fulfill()
                    }
        
        let response = StubResponse().setup(with: param)
        response.reply(via: fakeProtocol)
        
        waitForExpectations(timeout: delay + 1) { (error) in
            XCTAssertNil(error)
        }
        XCTAssertTrue(client.clientDidReceiveResponse)
        XCTAssertFalse(client.clientDidLoadData)
        let receivedResponse = client.response
        XCTAssertNotNil(receivedResponse)
        XCTAssertEqual(receivedResponse?.statusCode, 200)
        XCTAssertTrue(client.clientDidFinishLoading)
    }
    
    func testSetRepeatableToStubResponse() {
        let param = StubResponse.Parameter()
                    .setRepeatable(2)
        XCTAssertEqual(StubResponse().setup(with: param).repeatCount, 2)
    }
}
