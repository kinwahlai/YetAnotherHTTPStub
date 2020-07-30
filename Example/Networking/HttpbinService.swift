//
//  AlamofireService.swift
//  Example
//
//  Created by Darren Lai on 7/29/20.
//  Copyright © 2020 KinWahLai. All rights reserved.
//

import Foundation
import Alamofire

protocol HttpbinService {
    typealias ResquestResponse = ([String: Any]?, Error?) -> Void
}

struct ServiceParameter: Encodable {
    let token: String = UUID.init().uuidString
    let data: [String :String]
}

struct ServiceUsingAlamofire: HttpbinService {
    
    func getRequest(_ response: @escaping HttpbinService.ResquestResponse) {
        getRequest(with: "https://httpbin.org/get", response)
    }
    
    func getRequest(with urlString: String, _ response: @escaping HttpbinService.ResquestResponse) {
        AF.request(urlString).responseJSON { (res) in
            response(res.value as? [String: Any], res.error)
        }
    }
    
    func post(_ string: [String :String], _ response: @escaping HttpbinService.ResquestResponse) {
        AF.request("https://httpbin.org/post", method: .post, parameters: ServiceParameter(data: string), encoder: JSONParameterEncoder(), headers: ["accept":"application/json"])
            .responseJSON { (res) in
                let dict = res.value as? [String: Any]
            response(dict, res.error)
        }
    }
}
