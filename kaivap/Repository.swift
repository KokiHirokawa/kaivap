//
//  Repository.swift
//  kaivap
//
//  Created by KokiHirokawa on 2018/01/29.
//  Copyright © 2018年 KokiHirokawa. All rights reserved.
//

import Himotoki

struct ElevationEntity: Himotoki.Decodable {
    let results: [ElevationEntity.ItemEntity]
    
    struct ItemEntity: Himotoki.Decodable {
        let elevation: Double
        
        static func decode(_ e: Extractor) throws -> ElevationEntity.ItemEntity {
            return try ItemEntity(elevation: e <| "elevation")
        }
    }
    static func decode(_ e: Extractor) throws -> ElevationEntity {
        return try ElevationEntity(results: e <|| "results")
    }
}
