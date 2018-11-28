//
//  Builders.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/10/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

public func failure(_ error: StubError) -> (_ urlrequest: URLRequest) -> Response {
    return { (_ urlrequest: URLRequest) -> Response in
        return .failure(error)
    }
}

public func http(_ status:Int = 200, headers:[String:String]? = nil, content: StubContent = .noContent) -> (_ urlrequest: URLRequest) -> Response {
    return { (_ urlrequest: URLRequest) -> Response in
        let response = HTTPURLResponse(url: urlrequest.url!, statusCode: status, httpVersion: "HTTP/1.1", headerFields: headers)!
        return .success(response: response, content: content)
    }
}

public func jsonString(_ jsonString: String, status:Int = 200, headers:[String:String]? = nil) -> (_ urlrequest: URLRequest) -> Response {
    return { (_ urlrequest: URLRequest) -> Response in
        if let data = jsonString.data(using: String.Encoding.utf8) {
            return jsonData(data, status: status, headers: headers)(urlrequest)
        } else {
            return .failure(StubError.other("Failed to convert jsonString to Data"))
        }
    }
}

public func json(_ body: Any, status:Int = 200, headers:[String:String]? = nil) -> (_ urlrequest: URLRequest) -> Response {
    return { (_ urlrequest: URLRequest) -> Response in
        do {
            let data = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
            return jsonData(data, status: status, headers: headers)(urlrequest)
        } catch {
            return .failure(StubError.other("JSONSerialization failed"))
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

public func fileContent(_ url: URL, status:Int = 200, headers:[String:String]? = nil) -> (_ urlrequest: URLRequest) -> Response {
    return { (_ urlrequest: URLRequest) -> Response in
        do {
            let data = try Data(contentsOf: url)
            return http(status, headers: headers, content: .data(data))(urlrequest)
        } catch {
            return .failure(StubError.other("Reading file content failed"))
        }
    }
}

public func jsonFile(_ url: URL, status:Int = 200, headers:[String:String]? = nil) -> (_ urlrequest: URLRequest) -> Response {
    return { (_ urlrequest: URLRequest) -> Response in
        var headers = headers ?? [String:String]()
        if headers["Content-Type"] == nil {
            headers["Content-Type"] = "application/json; charset=utf-8"
        }
        return fileContent(url, status: status, headers: headers)(urlrequest)
    }
}
