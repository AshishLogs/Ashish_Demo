//
//  DomainErrorTests.swift
//  AshishDemoTests
//
//  Created by Ashish Singh on 16/11/25.
//

import XCTest
@testable import AshishDemo

final class DomainErrorTests: XCTestCase {
    
    func testInvalidQuantityErrorDescription() {
        
        let error = DomainError.invalidQuantity(-10)
        
        
        let description = error.errorDescription
        
        
        XCTAssertEqual(description, "Invalid quantity: -10")
    }
    
    func testInvalidPriceErrorDescription() {
        
        let error = DomainError.invalidPrice
        
        
        let description = error.errorDescription
        
        
        XCTAssertEqual(description, "Invalid price value")
    }
    
    func testCalculationErrorDescription() {
        
        let error = DomainError.calculationError
        
        
        let description = error.errorDescription
        
        
        XCTAssertEqual(description, "Calculation error occurred")
    }
    
    func testDomainErrorLocalizedError() {
        
        let error = DomainError.invalidQuantity(5) as LocalizedError
        
        
        let description = error.errorDescription
        
        
        XCTAssertNotNil(description)
        XCTAssertEqual(description, "Invalid quantity: 5")
    }
}

