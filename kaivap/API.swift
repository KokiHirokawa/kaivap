//
//  API.swift
//  kaivap
//
//  Created by KokiHirokawa on 2018/01/29.
//  Copyright © 2018年 KokiHirokawa. All rights reserved.
//

import Foundation
import APIKit
import Himotoki

protocol BaseRequest: Request {
}

extension BaseRequest {
    // これひとつしか使ってないのでワザワザこんなことしなくていい
    var baseURL: URL {
        return URL(string: "https://maps.googleapis.com")!
    }
    
    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        guard (200..<300).contains(urlResponse.statusCode) else {
            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }
        return object
    }
}

protocol GetRequest: BaseRequest { }
extension GetRequest {
    var method: HTTPMethod {
        return .get
    }
}

struct GetElevationRequest: GetRequest {
    typealias Response = ElevationEntity

    let locations: String
    var APIKey: String {
        guard let keyPlistFilePath = Bundle.main.path(forResource: "key", ofType: "plist") else { return "" }
        guard let keyDictionary = NSDictionary(contentsOfFile: keyPlistFilePath) as? [String: Any] else { return "" }
        
        return keyDictionary["GoogleMapsElevationAPIKey"] as! String
    }
    
    var path: String = "/maps/api/elevation/json"
    var parameters: Any? {
        return [
            "locations": locations,
            "key": APIKey
        ]
    }
    
    init(lat: Double, lng: Double) {
        self.locations = "\(lat),\(lng)"
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        print(object)
        return try decodeValue(object)
    }
}
