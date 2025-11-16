//
//  Holding.swift
//  AshishDemo
//
//  Created by Ashish Singh on 16/11/25.
//

import Foundation

struct Holding: Hashable, Identifiable {
    let id: String
    let symbol: String
    let quantity: Int
    let ltp: Double
    let avgPrice: Double
    let close: Double
    let pnl: Double
    
    init(
        symbol: String,
        quantity: Int,
        ltp: Double,
        avgPrice: Double,
        close: Double,
        pnl: Double
    ) throws {
        guard quantity >= 0 else {
            throw DomainError.invalidQuantity(quantity)
        }
        guard ltp > 0, avgPrice > 0, close > 0 else {
            throw DomainError.invalidPrice
        }
        guard ltp.isFinite, avgPrice.isFinite, close.isFinite, pnl.isFinite else {
            throw DomainError.invalidPrice
        }
        
        self.id = symbol.uppercased()
        self.symbol = symbol.uppercased()
        self.quantity = quantity
        self.ltp = ltp
        self.avgPrice = avgPrice
        self.close = close
        self.pnl = pnl
    }
}

enum DomainError: LocalizedError {
    case invalidQuantity(Int)
    case invalidPrice
    case calculationError
    
    var errorDescription: String? {
        switch self {
        case .invalidQuantity(let qty):
            return "Invalid quantity: \(qty)"
        case .invalidPrice:
            return "Invalid price value"
        case .calculationError:
            return "Calculation error occurred"
        }
    }
}

