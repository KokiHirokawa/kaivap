//
//  Repository.swift
//  kaivap
//
//  Created by KokiHirokawa on 2018/01/29.
//  Copyright © 2018年 KokiHirokawa. All rights reserved.
//

import Himotoki

struct ElevationEntity: Himotoki.Decodable {
    // 何故Arrayになってる??
    let results: [ElevationEntity.ItemEntity]
    // status受け取る
    // statusはErrorをEnumで制御する
    
    struct ItemEntity: Himotoki.Decodable {
        let elevation: Double
        
        var formattedElevation: String {
            return String(format: "%.1f", elevation)
        }
        
        static func decode(_ e: Extractor) throws -> ElevationEntity.ItemEntity {
            return try ItemEntity(elevation: e <| "elevation")
        }
    }
    static func decode(_ e: Extractor) throws -> ElevationEntity {
        return try ElevationEntity(results: e <|| "results")
    }
}
