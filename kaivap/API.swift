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
    var baseURL: URL {
        return URL(string: "https://cyberjapandata2.gsi.go.jp")!
    }
    
    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        guard (200..<300).contains(urlResponse.statusCode) else {
            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }
        return object
    }
}

//extension BaseRequest where Response: Decodable {
//    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
//        return try decodeValue(object)
//    }
//}

protocol GetRequest: BaseRequest { }
extension GetRequest {
    var method: HTTPMethod {
        return .get
    }
}

struct GetElevationRequest: GetRequest {
    
    typealias Response = ElevationEntity
    
    let lat: Double
    let lon: Double
    
    var path: String = "/general/dem/scripts/getelevation.php"
    var parameters: Any? {
        return [
            "lat": lat,
            "lon": lon,
            "outtype": "JSON"
        ]
    }
    
    init(lat: Double, lng: Double) {
        self.lat = lat
        self.lon = lng
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        print(object)
        return try decodeValue(object)
    }
}
