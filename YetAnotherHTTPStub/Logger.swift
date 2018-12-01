//
//  Logger.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 11/28/18.
//  Copyright © 2018 KinWahLai. All rights reserved.
//

import Foundation

let messageTemplate: String = "📦📦📦 %@"

func log(_ message: String) {
    guard StubSessionManager.sharedSession().debugEnabled else { return }
    let merged = String(format: messageTemplate, message)
    print(merged)
}
