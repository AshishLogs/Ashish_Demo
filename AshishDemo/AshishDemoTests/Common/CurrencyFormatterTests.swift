//
//  CurrencyFormatterTests.swift
//  AshishDemoTests
//
//  Created by Ashish Singh on 16/11/25.
//

import XCTest
@testable import AshishDemo

final class CurrencyFormatterTests: XCTestCase {
    
    private var formatter: CurrencyFormatter!
    
    override func setUp() {
        super.setUp()
        formatter = CurrencyFormatter()
    }
    
    override func tearDown() {
        formatter = nil
        super.tearDown()
    }
    
    
    func testFormatZero() {
        
        let value = 0.0
        
        
        let formatted = formatter.format(value)
        
        
        XCTAssertEqual(formatted, "₹ 0.00")
    }
        
    func testFormatSmallValue() {
        
        let value = 0.01
        
        
        let formatted = formatter.format(value)
        
        
        XCTAssertTrue(formatted.contains("₹"))
        XCTAssertTrue(formatted.contains("0.01"))
    }
    
    
    func testFormatNegativeZero() {
        
        let value = -0.0
        
        
        let formatted = formatter.format(value)
        
        
        // Should handle negative zero
        XCTAssertTrue(formatted.contains("₹"))
    }
    
    // MARK: - Edge Cases Tests
    
    func testFormatInfiniteValue() {
        
        let value = Double.infinity
        
        
        let formatted = formatter.format(value)
        
        
        XCTAssertEqual(formatted, "₹ 0.00")
    }
    
    func testFormatNegativeInfiniteValue() {
        
        let value = -Double.infinity
        
        
        let formatted = formatter.format(value)
        
        
        XCTAssertEqual(formatted, "₹ 0.00")
    }
    
    func testFormatNaN() {
        
        let value = Double.nan
        
        
        let formatted = formatter.format(value)
        
        
        XCTAssertEqual(formatted, "₹ 0.00")
    }
    
    // MARK: - Decimal Places Tests
    
    func testFormatTwoDecimalPlaces() {
        
        let value = 100.1
        
        
        let formatted = formatter.format(value)
        
        
        XCTAssertTrue(formatted.contains("100.10"))
    }
    
    func testFormatRoundsToTwoDecimals() {
        
        let value = 100.999
        
        
        let formatted = formatter.format(value)
        
        
        // Should round to 2 decimal places
        XCTAssertTrue(formatted.contains("101.00") || formatted.contains("100.99"))
    }
    
    // MARK: - Locale Tests
    
    func testFormatterWithCustomLocale() {
        
        let customFormatter = CurrencyFormatter(locale: Locale(identifier: "en_US"))
        let value = 1234.56
        
        
        let formatted = customFormatter.format(value)
        
        
        // Should still use ₹ symbol (as set in formatter)
        XCTAssertTrue(formatted.contains("₹"))
    }
}

