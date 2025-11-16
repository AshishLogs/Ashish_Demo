//
//  HoldingsMapper.swift
//  AshishDemo
//
//  Created by Ashish Singh on 16/11/25.
//

import Foundation

struct HoldingsMapper {
    static func map(_ dto: UserHoldingDTO) throws -> Holding {
        let pnl = (dto.ltp - dto.avgPrice) * Double(dto.quantity)
        guard pnl.isFinite else {
            throw DomainError.calculationError
        }
        return try Holding(
            symbol: dto.symbol,
            quantity: dto.quantity,
            ltp: dto.ltp,
            avgPrice: dto.avgPrice,
            close: dto.close,
            pnl: pnl
        )
    }
    
    static func map(_ dtos: [UserHoldingDTO]) throws -> [Holding] {
        try dtos.map(map)
    }
}

