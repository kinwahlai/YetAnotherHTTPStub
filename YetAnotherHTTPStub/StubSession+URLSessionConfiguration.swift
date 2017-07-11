//
//  StubSession+URLSessionConfiguration.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/10/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

let swizzleDefaultSessionConfiguration: Void = {
    let defaultSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.default))
    
    let yetAnotherHTTPStubDefaultSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.yetAnotherHTTPStubDefaultSessionConfiguration))
    
    method_exchangeImplementations(defaultSessionConfiguration, yetAnotherHTTPStubDefaultSessionConfiguration)
}()

let swizzleEphemeralSessionConfiguration: Void = {
    let ephemeralSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.ephemeral))
    
    let yetAnotherHTTPStubEphemeralSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.yetAnotherHTTPStubEphemeralSessionConfiguration))
    
    method_exchangeImplementations(ephemeralSessionConfiguration, yetAnotherHTTPStubEphemeralSessionConfiguration)
}()

extension URLSessionConfiguration {
    public class func swizzleYetAnotherHTTPStubSessionConfiguration() {
        _ = swizzleDefaultSessionConfiguration
        _ = swizzleEphemeralSessionConfiguration
    }
    
    class func yetAnotherHTTPStubDefaultSessionConfiguration() -> URLSessionConfiguration {
        let configuration = yetAnotherHTTPStubDefaultSessionConfiguration()
        var protocolClasses: [AnyClass] = Array(configuration.protocolClasses!)
        protocolClasses.insert(YetAnotherURLProtocol.self, at: 0)
        configuration.protocolClasses = protocolClasses
        return configuration
    }
    
    class func yetAnotherHTTPStubEphemeralSessionConfiguration() -> URLSessionConfiguration {
        let configuration = yetAnotherHTTPStubEphemeralSessionConfiguration()
        var protocolClasses: [AnyClass] = Array(configuration.protocolClasses!)
        protocolClasses.insert(YetAnotherURLProtocol.self, at: 0)
        configuration.protocolClasses = protocolClasses
        return configuration
    }
    
    
}
