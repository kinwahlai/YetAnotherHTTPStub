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
}

enum Httpbin {
    case simple
    case polling
    case withUrl(String)
    case complex(String, Alamofire.HTTPMethod)
}

extension Httpbin: TargetType {
    var baseURL: URL {
        switch self {
            case .simple: fallthrough
            case .polling:
                return URL(string: "https://httpbin.org")!
            case .withUrl(let urlString):
                return URL(string: urlString)!
            case .complex(let urlString, _):
                return URL(string: urlString)!
        }
    }
    
    var path: String {
        switch self {
            case .simple:
                return "/get"
            case .polling:
                return "/polling"
            case .withUrl(_): fallthrough
            case .complex(_, _):
                return ""
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
            case .simple: fallthrough
            case .polling: fallthrough
            case .withUrl(_):
                return .get
            case .complex(_, let method):
                return method
        }
    }
    
    var sampleData: Data {
        Data()
    }
    
    var task: Task {
        .requestPlain
    }
    
    var headers: [String : String]? {
        nil
    }
    
    
}
