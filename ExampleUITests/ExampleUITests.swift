//
//  ExampleUITests.swift
//  ExampleUITests
//
//  Created by Darren Lai on 7/30/20.
//  Copyright © 2020 KinWahLai. All rights reserved.
//

import XCTest
import YetAnotherHTTPStub

class ExampleUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
    }
    
    // YetAnotherURLProtocol doesnt work in UITest
    func xtestExampleWithGETrequest() throws {
        let app = XCUIApplication()
        
//        let bundle = Bundle(for: ExampleUITests.self)
//        guard let path = bundle.path(forResource: "GET", ofType: "json"), let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { XCTFail(); return }
//
//        YetAnotherURLProtocol.stubHTTP { (session) in
//            session.whenRequest(matcher: http(.get, uri: "/get"))
//            .thenResponse(responseBuilder: jsonData(data, status: 200))
//        }
        
        app.buttons["btn_get"].staticTexts["GET"].tap()
        sleep(1)
        XCTAssertEqual(app.staticTexts["originValue"].label, "9.9.9.9")
        XCTAssertEqual(app.staticTexts["urlValue"].label, "https://httpbin.org/get")
    }
    
    
    func xtestExampleWithPOSTrequest() {
        let app = XCUIApplication()
        
//        let bundle = Bundle(for: ExampleUITests.self)
//        guard let filePath: URL = Bundle(for: ExampleUITests.self).url(forResource: "POST", withExtension: "json") else { XCTFail(); return }
//
//        YetAnotherURLProtocol.stubHTTP { (session) in
//            session.whenRequest(matcher: http(.get, uri: "/post"))
//            .thenResponse(responseBuilder: jsonFile(filePath))
//        }
        
        app.buttons["btn_post"].staticTexts["POST"].tap()
        sleep(1)
        XCTAssertEqual(app.staticTexts["originValue"].label, "9.9.9.9")
        XCTAssertEqual(app.staticTexts["urlValue"].label, "https://httpbin.org/post")
    }
}
