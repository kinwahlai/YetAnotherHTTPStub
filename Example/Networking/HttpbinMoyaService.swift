//
//  HttpbinMoyaService.swift
//  Example
//
//  Created by Darren Lai on 7/30/20.
//  Copyright © 2020 KinWahLai. All rights reserved.
//

import Foundation
import Moya
import Alamofire

struct ServiceUsingMoya: HttpbinService {
    var provider = MoyaProvider<Httpbin>()
    func getRequest(_ response: @escaping HttpbinService.ResquestResponse) {
        provider.request(.simple) { (result) in
            switch result {
            case .success(let res):
              do {
                let dict = try res.mapJSON() as? [String: Any]
                response(dict, nil)
              } catch {
                response(nil, error)
              }
            case .failure(let failure):
                response(nil, failure)
            }
        }
    }
    
    func getRequest(with urlString: String, _ response: @escaping HttpbinService.ResquestResponse) {
        provider.request(.withUrl(urlString)) { (result) in
            switch result {
            case .success(let res):
              do {
                let dict = try res.mapJSON() as? [String: Any]
                response(dict, nil)
              } catch {
                response(nil, error)
              }
            case .failure(let failure):
                response(nil, failure)
            }
        }
    }
    
    func post(_ string: [String :String], _ response: @escaping HttpbinService.ResquestResponse) {
        provider.request(.post(string)) { (result) in
            switch result {
            case .success(let res):
              do {
                let dict = try res.mapJSON() as? [String: Any]
                response(dict, nil)
              } catch {
                response(nil, error)
              }
            case .failure(let failure):
                response(nil, failure)
            }
        }
    }
}

enum Httpbin {
    case simple
    case withUrl(String)
    case post([String: String])
}

extension Httpbin: TargetType {
    var baseURL: URL {
        switch self {
            case .simple:
                return URL(string: "https://httpbin.org")!
            case .withUrl(let urlString):
                return URL(string: urlString)!
            case .post(_):
                return URL(string: "https://httpbin.org")!
        }
    }
    
    var path: String {
        switch self {
            case .simple:
                return "/get"
            case .withUrl(_):
                return ""
            case .post(_):
                return "/post"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
            case .simple: fallthrough
            case .withUrl(_):
                return .get
            case .post(_):
                return .post
        }
    }
    
    var sampleData: Data {
        Data()
    }
    
    var task: Task {
        .requestPlain
    }
    
    var headers: [String : String]? {
        ["content-type":"application/json"]
    }
    
    
}
