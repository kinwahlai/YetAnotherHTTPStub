//
//  StubSessionManagerTests.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/8/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation
import XCTest
@testable import YetAnotherHTTPStub

class StubSessionManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSessionManagerCanCreateNewSession() {
        let hardcodedUUIDString = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
        let uuid = UUID(uuidString: hardcodedUUIDString)!
        
        let session1 = StubSessionManager.newSession()
        let session2 = StubSessionManager.newSession()
        let sessionWithFixedUUID = StubSessionManager.newSession(uuid)
        XCTAssertNotEqual(session1.uuid, session2.uuid)
        XCTAssertEqual(sessionWithFixedUUID.uuid.uuidString, hardcodedUUIDString)
    }
    
    func testSessionManagerHasSharedSession() {
        let session1 = StubSessionManager.sharedSession()
        let session2 = StubSessionManager.sharedSession()
        XCTAssertEqual(session1.uuid, session2.uuid)
    }
    
    func testSessionManagerCanResetSharedSession() {
        let session1 = StubSessionManager.sharedSession()
        StubSessionManager.removeSharedSession()
        let session2 = StubSessionManager.sharedSession()
        XCTAssertNotEqual(session1.uuid, session2.uuid)
    }
}
