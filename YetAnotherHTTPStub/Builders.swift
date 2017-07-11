//
//  Builders.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/10/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

public func failure(_ error: StubError) -> (_ urlrequest: URLRequest) -> StubResponse {
    return { (_ urlrequest: URLRequest) -> StubResponse in
        return .failure(error)
    }
}

public func http(_ status:Int = 200, headers:[String:String]? = nil, content: StubContent = .noContent) -> (_ urlrequest: URLRequest) -> StubResponse {
    return { (_ urlrequest: URLRequest) -> StubResponse in
        let response = HTTPURLResponse(url: urlrequest.url!, statusCode: status, httpVersion: "HTTP/1.1", headerFields: headers)!
        return .success(response: response, content: content)
    }
}

public func jsonString(_ jsonString: String, status:Int = 200, headers:[String:String]? = nil) -> (_ urlrequest: URLRequest) -> StubResponse {
    return { (_ urlrequest: URLRequest) -> StubResponse in
        if let data = jsonString.data(using: String.Encoding.utf8) {
            return jsonData(data, status: status, headers: headers)(urlrequest)
        } else {
            return .failure(StubError("Failed to convert jsonString to Data"))
        }
    }
}

public func json(_ body: Any, status:Int = 200, headers:[String:String]? = nil) -> (_ urlrequest: URLRequest) -> StubResponse {
    return { (_ urlrequest: URLRequest) -> StubResponse in
        do {
            let data = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
            return jsonData(data, status: status, headers: headers)(urlrequest)
        } catch {
            return .failure(StubError("JSONSerialization failed"))
        }
    }
}

public func jsonData(_ data: Data, status:Int = 200, headers:[String:String]? = nil) -> (_ urlrequest: URLRequest) -> StubResponse {
    return { (_ urlrequest: URLRequest) -> StubResponse in
        var headers = headers ?? [String:String]()
        if headers["Content-Type"] == nil {
            headers["Content-Type"] = "application/json; charset=utf-8"
        }
        return http(status, headers: headers, content: .data(data))(urlrequest)
    }
}
