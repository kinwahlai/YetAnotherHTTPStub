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

struct ServiceUsingAlamofire: HttpbinService {
    
    func getRequest(_ response: @escaping ResquestResponse) {
        getRequest(with: "https://httpbin.org/get", response)
    }
    
    func getRequest(with urlString: String, _ response: @escaping ResquestResponse) {
        AF.request(urlString).responseJSON { (res) in
            response(res.value as? [String: Any], res.error)
        }
    }
}
