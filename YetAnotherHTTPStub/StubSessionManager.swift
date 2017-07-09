//
//  StubSessionManager.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/8/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

public class StubSessionManager: NSObject {
    private static var _sharedSession: StubSession?
    public class func sharedSession() -> StubSession {
        if _sharedSession == nil {
            _sharedSession = StubSession()
        }
        return _sharedSession!
    }
    
    internal class func newSession() -> StubSession {
        return StubSession()
    }
    internal class func newSession(_ uuid: UUID) -> StubSession {
        return StubSession(uuid: uuid)
    }
    public class func removeSharedSession() {
        _sharedSession = nil
    }
}
