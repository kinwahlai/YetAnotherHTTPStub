//
//  Builders.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/10/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

public func failure(_ error: NSError) -> (_ urlrequest: URLRequest) -> Response {
    return { (_ urlrequest: URLRequest) -> Response in
        return Response.failure(error)
    }
}

public func http(_ status:Int = 200, headers:[String:String]? = nil, content: StubContent = .noContent) -> (_ urlrequest: URLRequest) -> Response {
    return { (_ urlrequest: URLRequest) -> Response in
        let response = HTTPURLResponse(url: urlrequest.url!, statusCode: status, httpVersion: "HTTP/1.1", headerFields: headers)!
        return Response.success(response: response, content: content)
    }
}

public func jsonString(_ jsonString: String, status:Int = 200, headers:[String:String]? = nil) -> (_ urlrequest: URLRequest) -> Response {
    return { (_ urlrequest: URLRequest) -> Response in
        if let data = jsonString.data(using: String.Encoding.utf8) {
            return jsonData(data, status: status, headers: headers)(urlrequest)
        } else {
            return .failure(NSError(domain: "YetAnotherTestError", code: 1, userInfo: nil))
        }
    }
}

public func json(_ body: Any, status:Int = 200, headers:[String:String]? = nil) -> (_ urlrequest: URLRequest) -> Response {
    return { (_ urlrequest: URLRequest) -> Response in
        do {
            let data = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
            return jsonData(data, status: status, headers: headers)(urlrequest)
        } catch {
            return .failure(NSError(domain: "YetAnotherTestError", code: 2, userInfo: nil))
        }
    }
}

public func jsonData(_ data: Data, status:Int = 200, headers:[String:String]? = nil) -> (_ urlrequest: URLRequest) -> Response {
    return { (_ urlrequest: URLRequest) -> Response in
        var headers = headers ?? [String:String]()
        if headers["Content-Type"] == nil {
            headers["Content-Type"] = "application/json; charset=utf-8"
        }
        return http(status, headers: headers, content: .data(data))(urlrequest)
    }
}
