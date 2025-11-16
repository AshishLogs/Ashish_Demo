//
//  HoldingsDTO.swift
//  AshishDemo
//
//  Created by Ashish Singh on 16/11/25.
//

import Foundation

struct HoldingsResponseDTO: Codable {
    let data: HoldingsDataDTO
}

struct HoldingsDataDTO: Codable {
    let userHolding: [UserHoldingDTO]
}

struct UserHoldingDTO: Codable {
    let symbol: String
    let quantity: Int
    let ltp: Double
    let avgPrice: Double
    let close: Double
}

