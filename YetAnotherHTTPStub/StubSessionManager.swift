//
//  StubSessionManager.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/8/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

class StubSessionManager {
    private static var _sharedSession: StubSession?
    class func sharedSession() -> StubSession {
        if _sharedSession == nil {
            _sharedSession = StubSession()
        }
        return _sharedSession!
    }
    class func newSession() -> StubSession {
        return StubSession()
    }
    class func newSession(_ uuid: UUID) -> StubSession {
        return StubSession(uuid: uuid)
    }
    class func removeSharedSession() {
        _sharedSession = nil
    }
}
