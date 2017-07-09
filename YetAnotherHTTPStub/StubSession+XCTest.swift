//
//  StubSession+XCTest.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/9/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation
import XCTest

extension StubSession: XCTestObservation {
    public func addToTestObserver() {
        XCTestObservationCenter.shared().addTestObserver(self)
    }
    
    public func testCaseDidFinish(_ testCase: XCTestCase) {
        if self.isProtocolRegistered {
            XCTestObservationCenter.shared().removeTestObserver(self)
            self.testCaseDidFinishBlock()
            StubSessionManager.removeSharedSession()
        }
    }
}
