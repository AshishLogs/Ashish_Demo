//
//  HoldingTests.swift
//  AshishDemoTests
//
//  Created by Ashish Singh on 16/11/25.
//

import XCTest
@testable import AshishDemo

final class HoldingTests: XCTestCase {
    
    // MARK: - Valid Initialization Tests
    
    func testValidHoldingInitialization() throws {
        
        let symbol = "RELIANCE"
        let quantity = 10
        let ltp = 2500.50
        let avgPrice = 2400.00
        let close = 2480.00
        let pnl = (ltp - avgPrice) * Double(quantity)
        
        
        let holding = try Holding(
            symbol: symbol,
            quantity: quantity,
            ltp: ltp,
            avgPrice: avgPrice,
            close: close,
            pnl: pnl
        )
        
        
        XCTAssertEqual(holding.symbol, "RELIANCE")
        XCTAssertEqual(holding.id, "RELIANCE")
        XCTAssertEqual(holding.quantity, quantity)
        XCTAssertEqual(holding.ltp, ltp)
        XCTAssertEqual(holding.avgPrice, avgPrice)
        XCTAssertEqual(holding.close, close)
        XCTAssertEqual(holding.pnl, pnl, accuracy: 0.01)
    }
    
    func testSymbolUppercased() throws {
        
        let symbol = "reliance"
        
        
        let holding = try Holding(
            symbol: symbol,
            quantity: 10,
            ltp: 2500.0,
            avgPrice: 2400.0,
            close: 2480.0,
            pnl: 1000.0
        )
        
        
        XCTAssertEqual(holding.symbol, "RELIANCE")
        XCTAssertEqual(holding.id, "RELIANCE")
    }
    
    func testZeroQuantity() throws {
        
        let quantity = 0
        
        
        let holding = try Holding(
            symbol: "RELIANCE",
            quantity: quantity,
            ltp: 2500.0,
            avgPrice: 2400.0,
            close: 2480.0,
            pnl: 0.0
        )
        
        
        XCTAssertEqual(holding.quantity, 0)
    }
    
    // MARK: - Invalid Initialization Tests
    
    func testNegativeQuantityThrowsError() {
        
        let quantity = -10
        
         & Then
        XCTAssertThrowsError(try Holding(
            symbol: "RELIANCE",
            quantity: quantity,
            ltp: 2500.0,
            avgPrice: 2400.0,
            close: 2480.0,
            pnl: -1000.0
        )) { error in
            if case DomainError.invalidQuantity(let qty) = error {
                XCTAssertEqual(qty, -10)
            } else {
                XCTFail("Expected invalidQuantity error")
            }
        }
    }
    
    func testZeroLTPThrowsError() {
         & Then
        XCTAssertThrowsError(try Holding(
            symbol: "RELIANCE",
            quantity: 10,
            ltp: 0.0,
            avgPrice: 2400.0,
            close: 2480.0,
            pnl: -1000.0
        )) { error in
            XCTAssertTrue(error is DomainError)
        }
    }
    
    func testNegativeLTPThrowsError() {
         & Then
        XCTAssertThrowsError(try Holding(
            symbol: "RELIANCE",
            quantity: 10,
            ltp: -2500.0,
            avgPrice: 2400.0,
            close: 2480.0,
            pnl: -1000.0
        )) { error in
            XCTAssertTrue(error is DomainError)
        }
    }
    
    func testZeroAvgPriceThrowsError() {
         & Then
        XCTAssertThrowsError(try Holding(
            symbol: "RELIANCE",
            quantity: 10,
            ltp: 2500.0,
            avgPrice: 0.0,
            close: 2480.0,
            pnl: 1000.0
        )) { error in
            XCTAssertTrue(error is DomainError)
        }
    }
    
    func testZeroCloseThrowsError() {
         & Then
        XCTAssertThrowsError(try Holding(
            symbol: "RELIANCE",
            quantity: 10,
            ltp: 2500.0,
            avgPrice: 2400.0,
            close: 0.0,
            pnl: 1000.0
        )) { error in
            XCTAssertTrue(error is DomainError)
        }
    }
    
    func testInfiniteLTPThrowsError() {
         & Then
        XCTAssertThrowsError(try Holding(
            symbol: "RELIANCE",
            quantity: 10,
            ltp: Double.infinity,
            avgPrice: 2400.0,
            close: 2480.0,
            pnl: 1000.0
        )) { error in
            XCTAssertTrue(error is DomainError)
        }
    }
    
    func testNaNLTPThrowsError() {
         & Then
        XCTAssertThrowsError(try Holding(
            symbol: "RELIANCE",
            quantity: 10,
            ltp: Double.nan,
            avgPrice: 2400.0,
            close: 2480.0,
            pnl: 1000.0
        )) { error in
            XCTAssertTrue(error is DomainError)
        }
    }
    
    func testInfinitePNLThrowsError() {
         & Then
        XCTAssertThrowsError(try Holding(
            symbol: "RELIANCE",
            quantity: 10,
            ltp: 2500.0,
            avgPrice: 2400.0,
            close: 2480.0,
            pnl: Double.infinity
        )) { error in
            XCTAssertTrue(error is DomainError)
        }
    }
    
    // MARK: - Hashable Tests
    
    func testHoldingHashable() throws {
        
        let holding1 = try Holding(
            symbol: "RELIANCE",
            quantity: 10,
            ltp: 2500.0,
            avgPrice: 2400.0,
            close: 2480.0,
            pnl: 1000.0
        )
        
        let holding2 = try Holding(
            symbol: "RELIANCE",
            quantity: 10,
            ltp: 2500.0,
            avgPrice: 2400.0,
            close: 2480.0,
            pnl: 1000.0
        )
        
        
        XCTAssertEqual(holding1.hashValue, holding2.hashValue)
        XCTAssertEqual(holding1, holding2)
    }
    
    func testHoldingNotEqual() throws {
        
        let holding1 = try Holding(
            symbol: "RELIANCE",
            quantity: 10,
            ltp: 2500.0,
            avgPrice: 2400.0,
            close: 2480.0,
            pnl: 1000.0
        )
        
        let holding2 = try Holding(
            symbol: "TCS",
            quantity: 10,
            ltp: 2500.0,
            avgPrice: 2400.0,
            close: 2480.0,
            pnl: 1000.0
        )
        
        
        XCTAssertNotEqual(holding1, holding2)
    }
    
    // MARK: - Identifiable Tests
    
    func testHoldingIdentifiable() throws {
        
        let holding = try Holding(
            symbol: "RELIANCE",
            quantity: 10,
            ltp: 2500.0,
            avgPrice: 2400.0,
            close: 2480.0,
            pnl: 1000.0
        )
        
        
        XCTAssertEqual(holding.id, "RELIANCE")
        XCTAssertEqual(holding.id, holding.symbol)
    }
    
    // MARK: - Edge Cases
    
    func testVeryLargeQuantity() throws {
        
        let quantity = Int.max
        
        
        let holding = try Holding(
            symbol: "RELIANCE",
            quantity: quantity,
            ltp: 2500.0,
            avgPrice: 2400.0,
            close: 2480.0,
            pnl: 1000.0
        )
        
        
        XCTAssertEqual(holding.quantity, Int.max)
    }
    
    func testVerySmallPrice() throws {
        
        let price = 0.0001
        
        
        let holding = try Holding(
            symbol: "RELIANCE",
            quantity: 10,
            ltp: price,
            avgPrice: price,
            close: price,
            pnl: 0.0
        )
        
        
        XCTAssertEqual(holding.ltp, price, accuracy: 0.00001)
    }
    
    func testNegativePNL() throws {
        
        let pnl = -1000.0
        
        
        let holding = try Holding(
            symbol: "RELIANCE",
            quantity: 10,
            ltp: 2300.0,
            avgPrice: 2400.0,
            close: 2480.0,
            pnl: pnl
        )
        
        
        XCTAssertEqual(holding.pnl, pnl)
    }
}

