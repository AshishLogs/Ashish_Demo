//
//  HoldingsMapperTests.swift
//  AshishDemoTests
//
//  Created by Ashish Singh on 16/11/25.
//

import XCTest
@testable import AshishDemo

final class HoldingsMapperTests: XCTestCase {
    
    // MARK: - Single DTO Mapping Tests
    
    func testMapSingleDTO() throws {
        
        let dto = UserHoldingDTO(
            symbol: "RELIANCE",
            quantity: 10,
            ltp: 2500.0,
            avgPrice: 2400.0,
            close: 2480.0
        )
        
        
        let holding = try HoldingsMapper.map(dto)
        
        
        XCTAssertEqual(holding.symbol, "RELIANCE")
        XCTAssertEqual(holding.quantity, 10)
        XCTAssertEqual(holding.ltp, 2500.0)
        XCTAssertEqual(holding.avgPrice, 2400.0)
        XCTAssertEqual(holding.close, 2480.0)
        XCTAssertEqual(holding.pnl, 1000.0, accuracy: 0.01) // (2500 - 2400) * 10
    }
    
    func testMapSingleDTOCalculatesPNLCorrectly() throws {
        
        let dto = UserHoldingDTO(
            symbol: "TCS",
            quantity: 5,
            ltp: 3500.0,
            avgPrice: 3400.0,
            close: 3480.0
        )
        
        
        let holding = try HoldingsMapper.map(dto)
        
        
        let expectedPNL = (3500.0 - 3400.0) * 5.0
        XCTAssertEqual(holding.pnl, expectedPNL, accuracy: 0.01)
    }
    
    func testMapSingleDTONegativePNL() throws {
        
        let dto = UserHoldingDTO(
            symbol: "RELIANCE",
            quantity: 10,
            ltp: 2300.0,
            avgPrice: 2400.0,
            close: 2480.0
        )
        
        
        let holding = try HoldingsMapper.map(dto)
        
        
        let expectedPNL = (2300.0 - 2400.0) * 10.0
        XCTAssertEqual(holding.pnl, expectedPNL, accuracy: 0.01)
        XCTAssertLessThan(holding.pnl, 0)
    }
    
    func testMapSingleDTOSymbolUppercased() throws {
        
        let dto = UserHoldingDTO(
            symbol: "reliance",
            quantity: 10,
            ltp: 2500.0,
            avgPrice: 2400.0,
            close: 2480.0
        )
        
        
        let holding = try HoldingsMapper.map(dto)
        
        
        XCTAssertEqual(holding.symbol, "RELIANCE")
    }
    
    // MARK: - Array Mapping Tests
    
    func testMapArrayOfDTOs() throws {
        
        let dtos = [
            UserHoldingDTO(
                symbol: "RELIANCE",
                quantity: 10,
                ltp: 2500.0,
                avgPrice: 2400.0,
                close: 2480.0
            ),
            UserHoldingDTO(
                symbol: "TCS",
                quantity: 5,
                ltp: 3500.0,
                avgPrice: 3400.0,
                close: 3480.0
            )
        ]
        
        
        let holdings = try HoldingsMapper.map(dtos)
        
        
        XCTAssertEqual(holdings.count, 2)
        XCTAssertEqual(holdings[0].symbol, "RELIANCE")
        XCTAssertEqual(holdings[1].symbol, "TCS")
    }
    
    func testMapEmptyArray() throws {
        
        let dtos: [UserHoldingDTO] = []
        
        
        let holdings = try HoldingsMapper.map(dtos)
        
        
        XCTAssertTrue(holdings.isEmpty)
    }
    
    // MARK: - Error Tests
    
    func testMapThrowsErrorForInvalidQuantity() {
        
        let dto = UserHoldingDTO(
            symbol: "RELIANCE",
            quantity: -10, // Invalid
            ltp: 2500.0,
            avgPrice: 2400.0,
            close: 2480.0
        )
        
         
        XCTAssertThrowsError(try HoldingsMapper.map(dto)) { error in
            XCTAssertTrue(error is DomainError)
        }
    }
    
    func testMapThrowsErrorForInvalidPrice() {
        
        let dto = UserHoldingDTO(
            symbol: "RELIANCE",
            quantity: 10,
            ltp: 0.0, // Invalid
            avgPrice: 2400.0,
            close: 2480.0
        )
        
         
        XCTAssertThrowsError(try HoldingsMapper.map(dto)) { error in
            XCTAssertTrue(error is DomainError)
        }
    }
    
    func testMapThrowsErrorForInfinitePNL() {
        
        let dto = UserHoldingDTO(
            symbol: "RELIANCE",
            quantity: Int.max,
            ltp: Double.greatestFiniteMagnitude,
            avgPrice: 1.0,
            close: 2480.0
        )
        
         
        XCTAssertThrowsError(try HoldingsMapper.map(dto)) { error in
            if case DomainError.calculationError = error {
                // Expected
            } else {
                XCTFail("Expected calculationError")
            }
        }
    }
    
    func testMapArrayStopsOnFirstError() {
        
        let dtos = [
            UserHoldingDTO(
                symbol: "RELIANCE",
                quantity: 10,
                ltp: 2500.0,
                avgPrice: 2400.0,
                close: 2480.0
            ),
            UserHoldingDTO(
                symbol: "INVALID",
                quantity: -10, // Invalid
                ltp: 2500.0,
                avgPrice: 2400.0,
                close: 2480.0
            ),
            UserHoldingDTO(
                symbol: "TCS",
                quantity: 5,
                ltp: 3500.0,
                avgPrice: 3400.0,
                close: 3480.0
            )
        ]
        
         
        XCTAssertThrowsError(try HoldingsMapper.map(dtos)) { error in
            XCTAssertTrue(error is DomainError)
        }
    }
    
    // MARK: - Edge Cases
    
    func testMapWithZeroQuantity() throws {
        
        let dto = UserHoldingDTO(
            symbol: "RELIANCE",
            quantity: 0,
            ltp: 2500.0,
            avgPrice: 2400.0,
            close: 2480.0
        )
        
        
        let holding = try HoldingsMapper.map(dto)
        
        
        XCTAssertEqual(holding.quantity, 0)
        XCTAssertEqual(holding.pnl, 0.0, accuracy: 0.01)
    }
    
    func testMapWithVeryLargeNumbers() throws {
        
        let dto = UserHoldingDTO(
            symbol: "RELIANCE",
            quantity: 1000000,
            ltp: 1000000.0,
            avgPrice: 999999.0,
            close: 1000001.0
        )
        
        
        let holding = try HoldingsMapper.map(dto)
        
        
        XCTAssertEqual(holding.quantity, 1000000)
        let expectedPNL = (1000000.0 - 999999.0) * 1000000.0
        XCTAssertEqual(holding.pnl, expectedPNL, accuracy: 0.01)
    }
    
    func testMapWithVerySmallNumbers() throws {
        
        let dto = UserHoldingDTO(
            symbol: "RELIANCE",
            quantity: 1,
            ltp: 0.0001,
            avgPrice: 0.0001,
            close: 0.0001
        )
        
        
        let holding = try HoldingsMapper.map(dto)
        
        
        XCTAssertEqual(holding.pnl, 0.0, accuracy: 0.00001)
    }
}

