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

class StubResponseTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testErrorResponse() {
        let client = URLProtocolClientSpy()
        let request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        let fakeProtocol = FakeURLProtocol(request: request, cachedResponse: nil, client: client)
        StubResponse(http(404)).reply(via: fakeProtocol)
        XCTAssertTrue(client.clientDidReceiveResponse)
        XCTAssertFalse(client.clientDidLoadData)
        let receivedResponse = client.response
        XCTAssertNotNil(receivedResponse)
        XCTAssertEqual(receivedResponse?.statusCode, 404)
        XCTAssertTrue(client.clientDidFinishLoading)
    }

    func testPostResponse() {
        let client = URLProtocolClientSpy()
        var request = URLRequest(url: URL(string: "https://httpbin.org/post")!)
        request.httpMethod = "POST"
        let fakeProtocol = FakeURLProtocol(request: request, cachedResponse: nil, client: client)
        StubResponse(http(200)).reply(via: fakeProtocol)
        XCTAssertTrue(client.clientDidReceiveResponse)
        XCTAssertFalse(client.clientDidLoadData)
        let receivedResponse = client.response
        XCTAssertNotNil(receivedResponse)
        XCTAssertEqual(receivedResponse?.statusCode, 200)
        XCTAssertTrue(client.clientDidFinishLoading)
    }

    func testGetResponse() {
        let client = URLProtocolClientSpy()
        var request = URLRequest(url: URL(string: "https://httpbin.org/get")!)
        request.httpMethod = "GET"
        let fakeProtocol = FakeURLProtocol(request: request, cachedResponse: nil, client: client)
        let responseBuilder: Builder = http(200, headers: ["Content-Type": "application/json; charset=utf-8"], content: .data("hello".data(using: String.Encoding.utf8)!))
        StubResponse(responseBuilder).reply(via: fakeProtocol)
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
        let client = URLProtocolClientSpy()
        var request = URLRequest(url: URL(string: "https://httpbin.org/get")!)
        request.httpMethod = "GET"
        let fakeProtocol = FakeURLProtocol(request: request, cachedResponse: nil, client: client)
        let responseBuilder: Builder = failure(StubError("There isn't any(more) response for this request \(request)"))
        StubResponse(responseBuilder).reply(via: fakeProtocol)
        XCTAssertTrue(client.clientDidFailedWithError)
    }
}
