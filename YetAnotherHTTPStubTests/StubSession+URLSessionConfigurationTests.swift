//
//  StubSession+URLSessionConfigurationTests.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/10/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation
import XCTest
@testable import YetAnotherHTTPStub

class StubSession_URLSessionConfigurationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCustomProtocolAddedToFirstInProtocolClassesForDefaultConfiguration() {
        _ = swizzleDefaultSessionConfiguration
        let configuration = URLSessionConfiguration.default
        let protocolClasses = (configuration.protocolClasses!).map({ "\($0)" })
        XCTAssertEqual(protocolClasses.first!, "YetAnotherURLProtocol")
    }
    
    func testCustomProtocolAddedToFirstInProtocolClassesForEphemeralConfiguration() {
        _ = swizzleEphemeralSessionConfiguration
        let configuration = URLSessionConfiguration.ephemeral
        let protocolClasses = (configuration.protocolClasses!).map({ "\($0)" })
        XCTAssertEqual(protocolClasses.first!, "YetAnotherURLProtocol")
    }
}
